#! /bin/sh
eval '  exec perl -x $0 ${1+"$@"} '
#! perl

print "Running $0 @ARGV\n";

print "Good Test\n";
print "Before: ";
print "\$? is $?.\n";
print `osf_test -p consscw -f 036100910031`;
print "After: ";
print "\$? is $?.\n\n";
$? = 0;

print "Bad Test\n";
print "Before: ";
print "\$? is $?.\n";
print `osf_test -p consscw -f FAKE_OSF`;
print "After: ";
print "\$? is $?.\n\n";
$? = 0;

print "No Print Good test\n";
print "Before: ";
print "\$? is $?.\n";
`osf_test -p consscw -f 036100910031`;
print "After: ";
print "\$? is $?.\n\n";

print "No Print bad test\n";
print "Before: ";
print "\$? is $?.\n";
`osf_test -p consscw -f FAKE`;
print "After: ";
print "\$? is $?.\n\n";


print "If good test\n";
print "Before: ";
print "\$? is $?.\n";
if ( `osf_test -p consscw -f 036100910031` ) {
	print "in if   : \$? is $?.\n";
} else {
	print "in else : \$? is $?.\n";
}
print "After: ";
print "\$? is $?.\n\n";


print "If bad test\n";
print "Before: ";
print "\$? is $?.\n";
if ( `osf_test -p consscw -f SOME_FAKE` ) {
	print "in if   : \$? is $?.\n";
} else {
	print "in else : \$? is $?.\n";
}
print "After: ";
print "\$? is $?.\n\n";


