Installing the Standard Library
________________________________

Move the folder StLib to your Shen home directory.  Enter Shen.

To install (cd "StLib") and type (load "install.shen").  If you can, save your image to an executable file 
- say shen-tk.exe. Exit.

Configuring for Shen/tk
______________________

In order to run Shen/tk you need to install TCL/tk. We recommend Active State TCL which is free for 
non-commercial applications.

1. Create two empty text files shen-to-tcl.txt and tcl-to-shen.txt in the home directory.  
2. Now go to StLib and look in the file Tk/root.tcl.  You will see two lines.

set in {C:/Users/shend/OneDrive/Desktop/Shen/S38.3/shen-to-tcl.txt} 
set out {C:/Users/shend/OneDrive/Desktop/Shen/S38.3/tcl-to-shen.txt}

You need to change these paths to the paths appropriate to your installation.

3. In Windows create a batch file with the following contents.

 START \B shen-tk.exe
 C:\ActiveTcl\bin\wish.exe "C:\Users\shend\OneDrive\Desktop\Shen\S38.1\StLib\Tk\root.tcl"
  
The last line is appropriate to my computer; you will have to change it for your installation.
Now click on the batch file and Shen/tk will open with a root window from TCL/tk.  

Note that the root window cannot be killed without ending your connection to TCL/tk.  This
is not true of other windows.  To exit cleanly without repercussions type (tk.exit) to the
REPL.

4.  To test under type checking. Enter 

(tc +)
(tk.types +)
(tk.widget .b button)
(tk.pack [.b])
(tk.putw .b -text "Hello World")
(tk.putw .b -command (freeze (pr "Hello World")))
(tk.tcl->shen)

Clicking the button should print 'Hello World'.  The file test.shen in the folder Tk contains
more examples.

Documentation for Shen/tk
__________________________

https://shenlanguage.org/Shentk.html 