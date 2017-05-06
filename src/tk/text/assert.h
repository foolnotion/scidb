/* assert.h */

#ifndef ASSERT_H_INCLUDED
#define ASSERT_H_INCLUDED

#ifdef NDEBUG

# define assert(expr) (void) (0)

#else

extern void assertionFailed(char const *message);
# define assert(expr) ((expr) ? (void) (0) : assertionFailed(__STRING(expr)))

#endif /* NDEBUG */
#endif /* ASSERT_H_INCLUDED */
