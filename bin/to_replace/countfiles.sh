for foo in * ; do echo `find "${foo}"  | wc -l` "        $foo" ; done
