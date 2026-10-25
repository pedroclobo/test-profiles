#!/bin/sh
tar -zxvf bzip2-1.0.8.tar.gz
tar -zxvf pbzip2-1.1.13.tar.gz
# remove gcc as default compiler (-i.orig: BSD sed needs a suffix)
grep -rl "CC=gcc" . | xargs sed -i.orig '/CC=gcc/d'
cd bzip2-1.0.8/
make
cp -f libbz2.a ../pbzip2-1.1.13
cp -f bzlib.h ../pbzip2-1.1.13
cd ..
cd pbzip2-1.1.13/
# libc++ no longer includes <new> transitively.
{ echo '#include <new>'; cat ErrorContext.cpp; } > ErrorContext.cpp.tmp && mv ErrorContext.cpp.tmp ErrorContext.cpp
# libc++ 19 dropped the generic std::char_traits, which
# std::basic_string<unsigned char> in BZ2StreamScanner relies on.
cat > uchar_traits.h <<'EOF'
#include <cstdio>
#include <cstring>
#include <cwchar>
#include <ios>
#include <string>
#if defined(_LIBCPP_VERSION)
namespace std {
template <> struct char_traits<unsigned char> {
  typedef unsigned char char_type;
  typedef int int_type;
  typedef streamoff off_type;
  typedef streampos pos_type;
  typedef mbstate_t state_type;
  static void assign(char_type &a, const char_type &b) { a = b; }
  static bool eq(char_type a, char_type b) { return a == b; }
  static bool lt(char_type a, char_type b) { return a < b; }
  static int compare(const char_type *a, const char_type *b, size_t n) { return n ? memcmp(a, b, n) : 0; }
  static size_t length(const char_type *s) { return strlen((const char *)s); }
  static const char_type *find(const char_type *s, size_t n, const char_type &c) { return n ? (const char_type *)memchr(s, c, n) : nullptr; }
  static char_type *move(char_type *d, const char_type *s, size_t n) { return n ? (char_type *)memmove(d, s, n) : d; }
  static char_type *copy(char_type *d, const char_type *s, size_t n) { return n ? (char_type *)memcpy(d, s, n) : d; }
  static char_type *assign(char_type *s, size_t n, char_type c) { return n ? (char_type *)memset(s, c, n) : s; }
  static int_type not_eof(int_type c) { return c == eof() ? 0 : c; }
  static char_type to_char_type(int_type c) { return (char_type)c; }
  static int_type to_int_type(char_type c) { return c; }
  static bool eq_int_type(int_type a, int_type b) { return a == b; }
  static int_type eof() { return EOF; }
};
}
#endif
EOF
{ echo '#include "uchar_traits.h"'; cat BZ2StreamScanner.h; } > BZ2StreamScanner.h.tmp && mv BZ2StreamScanner.h.tmp BZ2StreamScanner.h
grep -rl PRIuMAX . | xargs sed -i.orig 's/PRIuMAX/ PRIuMAX /g' # prevent clang error
make pbzip2-static
echo $? > ~/install-exit-status
cd ~
cat > compress-pbzip2 <<EOT
#!/bin/sh
cd pbzip2-1.1.13/
$PIN_CMD ./pbzip2 -v -c -p\$NUM_CPU_CORES -r -5 ../FreeBSD-13.0-RELEASE-amd64-memstick.img > /dev/null 2>\$LOG_FILE
EOT
chmod +x compress-pbzip2
