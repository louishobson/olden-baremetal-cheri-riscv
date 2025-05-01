#include <stdlib.h>

void putchar(char);
void exit(int);

//unsigned int heapCurrent = 0x40000000;
//extern unsigned int end;
//extern unsigned int heapCurrent;

void _fini() {}
void __exidx_start() {}
void __exidx_end() {}

void __errno() {}

int _isatty()
{
  return 0;
}
int _fstat()
{
  return 0;
}

void puts(char *string)
{
    int index = 0;
    while(string[index] != '\0')
    {
        putchar(string[index]);
        ++index;
    }
}

extern char __heap_start[]; /* __heap_start and __heap_end are set in the linker command file */
//extern char __heap_end[];
char *heap_ptr;

/*
 * sbrk -- changes heap size size. Get nbytes more
 *         RAM. We just increment a pointer in what's
 *         left of memory on the board.
 */
char *
_sbrk (nbytes)
     int nbytes;
{
  char *base;
  if (!heap_ptr)
    heap_ptr = (char *)&__heap_start;
  base = heap_ptr;
  heap_ptr += nbytes;

  return base;
}

/*
void * _sbrk(int increment)
{
    heapCurrent += increment;

    if(heapCurrent >= _end)
    {
        exit(1);
    }

    return (void *)heapCurrent;

    return NULL;
}
*/

/*
int rand(void)
{
    return 7;
}

void srand(unsigned __seed)
{
  return;
}
*/

// Default behavior is for GCC to send printf output here
int _write(int fd, const unsigned char *buf, int count)
{
    int cnt;
    for(cnt = 0; cnt < count; ++cnt)
    {
        putchar(*buf);
	++buf;
    }

    return cnt;
}

void _close()
{
    return;
}

void _read()
{
    return;
}

void _lseek()
{
    return;
}

int _kill (int  pid, int  sig) {
  return -1;
}

int _getpid ()
{
  return  1;
}
