H-I-H ( HIghlight Helper )
==========================

## What is it ?

HIH Provide a command to ease vim highlighting


## How to use it ?


This set the front color to red for the group *my_group*
```vim
HI my_group #FF0000 -
```

It is possible to mimic some value of an other group.

This is how to set the backgroup of *foo* like the background of *bar*
```vim
HI foo - @bar -
```
