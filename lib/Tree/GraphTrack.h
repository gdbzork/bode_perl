/* GraphTrack.h */

typedef struct redBlackNode {
  int key; /* node key value */
  char isRed; /* 1 for red, 0 for black */
  struct redBlackNode *left;
  struct redBlackNode *right;
  struct redBlackNode *parent;
  int noderight;
  int height;
} *redBlackNodeP;

typedef struct graphTrack {
  int count; /* nodes currently in tree */
  redBlackNodeP root;
} *graphTrackP;

graphTrackP new();
void addSegment(graphTrackP rbt,int left,int right,int incr);
int getCount(graphTrackP rbt);
redBlackNodeP search(graphTrackP rbt,int key);

int getLeft(redBlackNodeP rbn);
int getHeight(redBlackNodeP rbn);
int getRight(redBlackNodeP rbn);
int isNull(redBlackNodeP rbn);
void dumpIntervals(graphTrackP rbt);
