H-I-H ( HIghlight Helper )
==========================

## What is it ?

HIH is a Vim plugin that provides a command to ease highlighting configuration.

The credit for the original idea ( an advanced *hi* command called *HI* ) goes to... someone else.


## How to use it ?

This set the front color to red for the group *my_group*.
```vim
HI my_group #FF0000 - -
```

It is possible to mimic some value of an other group.

This is how to set the background of *foo* like the background of *bar*.
```vim
HI foo - @bar -
```

Like the previous example, this one also use *bar*'s background but fifty percent darker[^color_modification].
```vim
HI foo - @bar<l=0.5 -
```
And this one use *bar*'s background with lightness twenty percent higher.
```vim
HI foo - @bar>l=20% -
```



Let's set the *caution* group's background to yellow. Also make the text bold.
```vim
HI caution - yellow bold
```


## RGB Color versus CTerm color

When a RGB color is given, HI find the closest color amongst the 256 colors known by cterm. Therefore when seen in a 256 color terminal rendered colors might be not accurate.

But when a 'cterm' color is given (i.e. *red*, *blue*, ...), it is converted to its RGB equivalent, so there is no color loss in a gui or a true color terminal.


[^color_modification]: Syntax for make lightness higher is `>l=[amount]`, change `>` for `<` to make it darker. Amount can be a number between 0 and 1 or a percentage.

