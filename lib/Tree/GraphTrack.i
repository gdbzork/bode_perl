%module "Tree::GraphTrack"

%{
#include "GraphTrack.h"
%}

graphTrackP new();
void addSegment(graphTrackP rbt,int left,int right,int incr);
int getCount(graphTrackP rbt);
redBlackNodeP search(graphTrackP rbt,int key);

int getLeft(redBlackNodeP rbn);
int getHeight(redBlackNodeP rbn);
int getRight(redBlackNodeP rbn);
int isNull(redBlackNodeP rbn);
void dumpIntervals(graphTrackP rbt);
