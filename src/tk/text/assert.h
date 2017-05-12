/* assert.h */

#ifndef ASSERT_H_INCLUDED
#define ASSERT_H_INCLUDED

#ifdef NDEBUG

# define assert(expr) (void) (0)

#else

extern void assertionFailed(char const* expr, char const* file, unsigned line, char const* func);
# define assert(expr) ((expr) ? (void) (0) : assertionFailed(__STRING(expr),  __FILE__, __LINE__, __func__))

#endif /* NDEBUG */
#endif /* ASSERT_H_INCLUDED */
