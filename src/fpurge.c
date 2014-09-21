/*
 * Copyright © 2011 Guillem Jover <guillem@hadrons.org>
 *
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions
 * are met:
 * 1. Redistributions of source code must retain the above copyright
 *    notice, this list of conditions and the following disclaimer.
 * 2. Redistributions in binary form must reproduce the above copyright
 *    notice, this list of conditions and the following disclaimer in the
 *    documentation and/or other materials provided with the distribution.
 * 3. The name of the author may not be used to endorse or promote products
 *    derived from this software without specific prior written permission.
 *
 * THIS SOFTWARE IS PROVIDED ``AS IS'' AND ANY EXPRESS OR IMPLIED WARRANTIES,
 * INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY
 * AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED.  IN NO EVENT SHALL
 * THE AUTHOR BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL,
 * EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO,
 * PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS;
 * OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY,
 * WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR
 * OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF
 * ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 */

#include <errno.h>
#include <stdio.h>
#if HAVE___FPURGE
#include <stdio_ext.h>
#endif

#ifdef HAVE___FPURGE                   /* glibc >= 2.2, Haiku, Solaris >= 7 */
int
fpurge(FILE *fp)
{
	if (fp == NULL || fileno(fp) < 0) {
		errno = EBADF;
		return EOF;
	}

	__fpurge(fp);

	return 0;
}
#else
#define fp_ fp
//#error "Function fpurge() needs to be ported."
//#elif HAVE_FPURGE                   /* FreeBSD, NetBSD, OpenBSD, DragonFly, Mac OS X, Cygwin 1.7 */
int
fpurge(FILE *fp)
{
	if (fp == NULL || fileno(fp) < 0) {
		errno = EBADF;
		return EOF;
	}

  /* Call the system's fpurge function.  */
# undef fpurge
# if !HAVE_DECL_FPURGE
  extern int fpurge (FILE *);
# endif
  int result = fpurge (fp);
# if defined __sferror || defined __DragonFly__ /* FreeBSD, NetBSD, OpenBSD, DragonFly, Mac OS X, Cygwin */
  if (result == 0)
    /* Correct the invariants that fpurge broke.
       <stdio.h> on BSD systems says:
         "The following always hold: if _flags & __SRD, _w is 0."
       If this invariant is not fulfilled and the stream is read-write but
       currently reading, subsequent putc or fputc calls will write directly
       into the buffer, although they shouldn't be allowed to.  */
    if ((fp_->_flags & __SRD) != 0)
      fp_->_w = 0;
#endif
  return result;
}
//#endif
#endif

#ifdef TEST
int
main()
{
	static FILE fp_bad;
	FILE *fp;

	if (fpurge(&fp_bad) == 0)
		return 1;

	fp = fopen("/dev/zero", "r");
	if (fpurge(fp) < 0)
		return 1;

	fclose(fp);

	return 0;
}
#endif
