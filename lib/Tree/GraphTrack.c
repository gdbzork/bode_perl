#include <stdio.h>
#include <stdlib.h>

#include "GraphTrack.h"

#define ISRED(x) ((x)->isRed==1)
#define SETRED(x) ((x)->isRed = 1)
#define SETBLACK(x) ((x)->isRed = 0)

#ifdef DEBUG
#define TRACE(...) (fprintf(stderr,__VA_ARGS__))
#else
#define TRACE(...)
#endif

void printNode(redBlackNodeP rbn) {
  fprintf(stderr,"%d\t%d\t%d\n",rbn->key,rbn->noderight-1,rbn->height);
  fflush(stderr);
}

graphTrackP new() {
  graphTrackP x = (graphTrackP) malloc(sizeof(struct graphTrack));
  x->root = NULL;
  x->count = 0;
  return x;
}

redBlackNodeP node_new(int k,int right,int height) {
  redBlackNodeP x = (redBlackNodeP) malloc(sizeof(struct redBlackNode));
  x->key = k;
  x->isRed = 1;
  x->left = NULL;
  x->right = NULL;
  x->parent = NULL;
  x->noderight = right;
  x->height = height;
  return x;
}

void node_insert(graphTrackP rbt,redBlackNodeP rbn) {
  redBlackNodeP y = NULL;
  redBlackNodeP x = rbt->root;
  while (x != NULL) {
    y = x;
    if (rbn->key < x->key) {
      x = x->left;
    } else {
      x = x->right;
    }
  }
  rbn->parent = y;
  if (y == NULL) {
    rbt->root = rbn;
  } else if (rbn->key < y->key) {
    y->left = rbn;
  } else {
    y->right = rbn;
  }
}

void leftRotate(graphTrackP rbt,redBlackNodeP rbn) {
  redBlackNodeP y = rbn->right;
  rbn->right = y->left;
  if (y->left != NULL) {
    y->left->parent = rbn;
  }
  y->parent = rbn->parent;
  if (rbn->parent == NULL) {
    rbt->root = y;
  } else if (rbn == rbn->parent->left) {
    rbn->parent->left = y;
  } else {
    rbn->parent->right = y;
  }
  y->left = rbn;
  rbn->parent = y;
}

void rightRotate(graphTrackP rbt,redBlackNodeP rbn) {
  redBlackNodeP y = rbn->left;
  rbn->left = y->right;
  if (y->right != NULL) {
    y->right->parent = rbn;
  }
  y->parent = rbn->parent;
  if (rbn->parent == NULL) {
    rbt->root = y;
  } else if (rbn == rbn->parent->right) {
    rbn->parent->right = y;
  } else {
    rbn->parent->left = y;
  }
  y->right = rbn;
  rbn->parent = y;
}

redBlackNodeP insert(graphTrackP rbt,int key,int right,int height) {
  redBlackNodeP x = node_new(key,right,height);
  redBlackNodeP orig = x;
  node_insert(rbt,x);
  while (x!=rbt->root && ISRED(x->parent)) {
    if (x->parent->parent->left == x->parent) {
      redBlackNodeP y = x->parent->parent->right;
      if (y != NULL && ISRED(y)) {
        SETBLACK(x->parent);
        SETBLACK(y);
        SETRED(x->parent->parent);
        x = x->parent->parent;
      } else {
        if (x == x->parent->right) {
          x = x->parent;
          leftRotate(rbt,x);
        }
        SETBLACK(x->parent);
        SETRED(x->parent->parent);
        rightRotate(rbt,x->parent->parent);
      }
    } else {
      redBlackNodeP y = x->parent->parent->left;
      if (y != NULL && ISRED(y)) {
        SETBLACK(x->parent);
        SETBLACK(y);
        SETRED(x->parent->parent);
        x = x->parent->parent;
      } else {
        if (x == x->parent->left) {
          x = x->parent;
          rightRotate(rbt,x);
        }
        SETBLACK(x->parent);
        SETRED(x->parent->parent);
        leftRotate(rbt,x->parent->parent);
      }
    }
  }
  SETBLACK(rbt->root);
  return orig;
}

redBlackNodeP splitNode(graphTrackP rbt,redBlackNodeP rbn,int position) {
  int currentRight;

  currentRight = rbn->noderight;
  rbn->noderight = position;
  return insert(rbt,position,currentRight,rbn->height);
}

redBlackNodeP node_search(redBlackNodeP rbn,int key) {
  
  if (rbn == NULL || (rbn->key <= key && rbn->noderight > key)) {
    return rbn;
  }
  if (key < rbn->key) {
    return node_search(rbn->left,key);
  } else {
    return node_search(rbn->right,key);
  }
}

redBlackNodeP search(graphTrackP rbt,int key) {
  return node_search(rbt->root,key);
}

redBlackNodeP node_searchLeft(redBlackNodeP rbn,int key) {
  redBlackNodeP hit;
  if (rbn == NULL || (rbn->key <= key && rbn->key+rbn->noderight > key)) {
    return rbn;
  }
  if (key < rbn->key) {
    return node_search(rbn->left,key);
  } else {
    hit = node_search(rbn->right,key);
    if (hit == NULL) {
      return rbn;
    } else {
      return hit;
    }
  }
}

redBlackNodeP node_searchRight(redBlackNodeP rbn,int key) {
  redBlackNodeP hit;
  if (rbn == NULL || (rbn->key <= key && rbn->key+rbn->noderight > key)) {
    return rbn;
  }
  if (key < rbn->key) {
    hit = node_search(rbn->left,key);
    if (hit == NULL) {
      return rbn;
    } else {
      return hit;
    }
  } else {
    return node_search(rbn->right,key);
  }
}

redBlackNodeP stepLeft(redBlackNodeP node) {
  redBlackNodeP other = NULL;

  if (node->left != NULL) {
    other = node->left;
    while (other->right != NULL) {
      other = other->right;
    }
  } else {
    other = node->parent;
    while (other->parent != NULL && node == other->left) {
      node = other;
      other = other->parent;
    }
  }
  return other;
}

redBlackNodeP stepRight(redBlackNodeP node) {
  redBlackNodeP other = NULL;

  if (node->right != NULL) {
    other = node->right;
    while (other->left != NULL) {
      other = other->left;
    }
  } else {
    other = node->parent;
    while (other->parent != NULL && node == other->right) {
      node = other;
      other = other->parent;
    }
    if (other->parent == NULL && node == other->right) {
      /* we're at the root, never having moved left, so next is null */
      other = NULL;
    }
  }
  return other;
}

void addSegment(graphTrackP rbt,int left,int right,int incr) {
  redBlackNodeP current,next;
  
  current = node_searchRight(rbt->root,left);
  if (current == NULL || current->key >= right) {
    /* we're to the right of the whole tree, or in a gap, so just insert
       a new node of the appropriate height */
    TRACE("inserting into gap or right of tree...\n");
    (void) insert(rbt,left,right,incr);
  } else {
    if (current->key > left) {
      /* we're in a gap between nodes, but won't fit into the gap.
         insert a node from here to the next one, then we're at the start of
         a node */
      (void) insert(rbt,left,current->key,incr);
      left = current->key;
      TRACE("filling gap to right... %d to %d current=%d\n",left,right,current->key);
    } else if (current->key < left) {
      /* we're in a node, so we'll have to split it */
      TRACE("splitting node... %d to %d at %d\n",current->key,current->noderight,left);
      current = splitNode(rbt,current,left);
    }
    /* now we're at the beginning of a node, one way or another. */
    TRACE("now ready to traverse right... current=%d\n",current->key);
    while (left < right) {
      if (current != NULL && current->key == left) {
        if (current->noderight > right) {
          /* need to split the current node, only increment part */
          splitNode(rbt,current,right);
        }
        /* we're not in a gap, so increment the current node by incr */
        TRACE("incrementing node... %d to %d height=%d to %d\n",current->key,current->noderight,current->height,current->height+incr);
        current->height += incr;
        left = current->noderight;
        current = stepRight(current);
      } else {
        /* we're in a gap, or we're off the edge of the world. */
        if (current != NULL) {
          /* we're in a gap */
          if (right <= current->key) {
            /* we don't span the whole gap */
            (void) insert(rbt,left,right,incr);
            left = right;
            TRACE("partially filling gap... %d to %d current=%d\n",left,right,current->key);
          } else {
            TRACE("filling gap... %d to %d currrent=%d\n",left,current->key,current->key);
            (void) insert(rbt,left,current->key,incr);
            left = current->key;
          }
        } else {
          /* we're off the edge of the world (or tree, rather) */
          (void) insert(rbt,left,right,incr);
          left = right;
          TRACE("extending to right... %d to %d\n",left,right);
        }
      }
    }
  }
  rbt->count++;
}

int count(graphTrackP rbt) {
  return rbt->count;
}

int getLeft(redBlackNodeP rbn) {
  return rbn->key;
}

int getHeight(redBlackNodeP rbn) {
  return rbn->height;
}

int getRight(redBlackNodeP rbn) {
  return rbn->noderight;
}

int isNull(redBlackNodeP rbn) {
  return rbn == NULL;
}

void inOrderTraverse(redBlackNodeP rbn,void (*action)(redBlackNodeP)) {
  if (rbn->left != NULL) {
    inOrderTraverse(rbn->left,action);
  }
  (*action)(rbn);
  if (rbn->right != NULL) {
    inOrderTraverse(rbn->right,action);
  }
}

void dumpIntervals(graphTrackP rbt) {
  inOrderTraverse(rbt->root,&printNode);
}
