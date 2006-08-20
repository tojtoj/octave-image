#!/usr/bin/perl -w -n

## defines function change_line that transforms old-style variable argument
## lists (...) into new-style varargin. va_arg() etc are also transformed.

BEGIN{

    $va_arg_re = qr!^(\s*function\s*\w*.*?\(.*?)\.\.\.(\s*\).*)$!;
    
}

## Does necessary changes inplace on $_[0].
sub change_line {
    
    if ($_[0] !~ /^\s*\#/) {	# Don't do obvious comment lines

				# Transform ... in function decalaration

	$_[0] =~ s{$va_arg_re}{$1varargin$2}og;

				# list(all_va_args) becomes varargin

	$_[0] =~ s!list\s*\(\s*all_va_args\s*\)!varargin!og;

				# all_va_args becomes varargin{:}

	$_[0] =~ s!all_va_args!varargin{:}!og;

				# va_start() can be delicate, so add a
				# warning. 

				# declare a va_arg_cnt counter

	$_[0] =~ s!(.*\b)va_start\b(\s*\(\s*\)|)(.*)!$1va_arg_cnt = 1$3\nwarn ("va_start should be transformed\\n");\n!g;

				# Use that counter to substitute va_arg by
				# nth (varargin, va_arg_cnt++)

	$_[0] =~ s!(.*\b)va_arg\b(\s*\(\s*\)|)(.*)!$1nth (varargin, va_arg_cnt++)$3!g;
    }
}

## Does it look like an underlined func that is not a function call?
sub comment_line {
     0 ?
	"## Hmmm ... is that a function call?\n" : "";
}
1;
