load ('../src/mylib.js');

(function (a) {
   if (MyLib.dude (0) === "my car")
     {
       quit ();
     }
   else
     {
       quit (1);
     }
}) (arguments);
