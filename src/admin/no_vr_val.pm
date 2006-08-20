#!/usr/bin/perl -w -n

## Catches vr_val (x) transforms it into varargout(i++) = x;
## 

use OctRe;

BEGIN {
    $first = "vr_val_cnt = 1; ";

}

## Does necessary changes inplace on $_[0].
sub change_line {
    
    if ($_[0] !~ /^\s*\#/) {	# Don't do obvious comment lines

				# Change function declaration
	if ($_[0] =~ /$defun_rx/) {
	    $_[0] =~ s/\.\.\.(\s*\]\s*\=)/varargout$1/g;
	}
				# Change vr_val()

				# BTW, if 1st vr_val() occurs in a loop,
				# this will NOT WORK!

	if ($_[0] =~ 
	    s{vr_val\s*\(([^;]*)\)(\s*;)}
	    {"$first" . "varargout\{vr_val_cnt++\} = $1$2"}eg) {

	    $first = "";
	}
				# Did I miss anything?
	if ($_[0] =~ /vr_val\s*\(/) {
	    $_[0] .= "## TODO : Remove this vr_val\n";
	}

    }
    $first = "vr_val_cnt = 1; " if $. == 1;
}

sub comment_line {
    ""
}
1;
