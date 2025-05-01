/* For copyright information, see olden_v1.0/COPYRIGHT */

/* tree-alloc.c
 */

#ifndef TORONTO
#include "mem-ref.h"
#include "future-cell.h"
#endif

#define INVERSE_ALLOC_PROB 2
#define MIN_ALLOC_SIZE 16
#define MAX_ALLOC_SIZE 1024

#include "tree.h"

// extern void *malloc(unsigned);
#include <stdlib.h>

tree_t *TreeAlloc (int level, int lo, int proc) {
  if (level == 0)
    return NULL;
  else {
    struct tree *new, *right, *left;
    if (rand() % INVERSE_ALLOC_PROB == 0) {
      int size = (rand() % (MAX_ALLOC_SIZE-MIN_ALLOC_SIZE)) + MIN_ALLOC_SIZE;
      malloc(size);
    }
    new = (struct tree *) malloc(sizeof(tree_t));
    left = TreeAlloc(level -1, lo+proc/2, proc/2);
    right=TreeAlloc(level-1,lo,proc/2);
    new->val = 1;
    new->left = (struct tree *) left;
    new->right = (struct tree *) right;
    return new;
  }
}
