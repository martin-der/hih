H-I-H ( HIghlight Helper )
==========================

## What is it ?

HIH Provide a command to ease vim highlighting configuration

The credit for the original idea ( an advanced *hi* command called *HI* ) goes to... someone else.


## How to use it ?

This set the front color to red for the group *my_group*
```vim
HI my_group #FF0000 - -
```

It is possible to mimic some value of an other group.

This is how to set the backgroup of *foo* like the background of *bar*
```vim
HI foo - @bar bold
```


Let's set le *caution* group's background to yellow.
```vim
HI caution - yellow -
```


## RGB Color versus CTerm color

When a RGB color is given, HI find the closest color amongst the 256 colors known by cterm. Therefore when seen in a 256 color terminal rendered colors might be not accurate.

But when a 'cterm' color is given (i.e. *red*, *blue*, ...), it is converted to its RGB equivalent, so there is no color loss in a gui or a true color terminal.

