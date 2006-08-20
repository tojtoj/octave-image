#!/usr/bin/perl -w

=head1 NAME OctRe - Regexes for octave code

Regexpes come in pairs, I<$XYZ_re>,which don't set I<$1, $2, ...>
and I<$XYZ_rx>, which do.

=over 4

=item I<$var_r[ex]> match an octave variable (sets I<$1>)

=item I<$dot_r[ex]> match an ellipsis (sets I<$1>)

=item I<$vl_r[ex]> match a variable list, as it appears in a function
call (sets I<$1>). The individual variables in $1  can be retrieved
with /$var_rx/g. Example : "x, y, z".

=item I<retl_r[xe]> match a return list, as it appears in a function
declaration (sets I<$1>). The individual variables in $1 can be
retrieved with /$var_rx/g. Example : "[x]", "[ x, y]", "[x,y,z]",
"[x,...]".

=item I<retl_r[xe]> match an argument list, as it appears in a
function declaration (sets I<$1>). The individual variables in $1 can
be retrieved with /$var_rx/g. Example : "(x)", "( x, y)", "(x,y,z)",
"(x,...)".

=back

Rem : This is not a true module, as no package is used. It just declares
some regexes.

=cut

## Variable $1 : variable name
$var_re = qr{\s*[A-Za-z\_]+\w*\s*} ;
$var_rx = qr{\s*([A-Za-z\_]+\w*)\s*} ;

## Ellipsis $1 : ellipsis
$dot_re = qr{\.\.\.} ;
$dot_rx = qr{(\.\.\.)} ; # qr{(${var_re})(?:\,(${var_re}))*} ;

## Variable list : $1, $2 ... variable names
$vl_re = qr{${var_re}(?:\,${var_re})*} ;
$vl_rx = qr{(${var_re})(?:\,(${var_re}))*} ;

## Return list (as in function declaration)
## $1, $2 ... : variable names (or ellipsis at end)
$retl_re = qr{(?:\[\s*(?:${vl_re}(?:,$dot_re)?|$dot_re|)\s*\]|${var_re})\s*\=|} ;
$retl_rx = qr{(?:\[\s*(?:${vl_rx}(?:,$dot_rx)?|$dot_rx|)\s*\]|${var_rx})\s*\=|} ;

# Simple assignment $1 : lhs name
$sas_re = qr{${var_re}\s*\=} ;
$sas_rx = qr{${var_rx}\s*\=} ;

## Return list, as in function call. Call it "mas" like multiple
## assignment.
# $1, $2, ... : variable names
$mas_re = qr{(?:\[(?:${vl_re})\]|${var_re})\s*\=} ;
$mas_rx = qr{(?:\[(?:${vl_rx})\]|${var_rx})\s*\=} ;

## Arg list as in function declaration
## $1, $2, ... : variable names
$argl_re = qr{(?:\((?:${vl_re}(?:,$dot_re)?|$dot_re|)\)|)} ;
$argl_rx = qr{(?:\((?:${vl_rx}(?:,$dot_rx)?|$dot_rx|)\)|)} ;

## $retl_re = qr{(?:\((?:${vl_re}(?:,$dot_re)?|$dot_re|)\)|)} ;

## $argl_re = qr{\((?:${var_re}(?:\,${var_re})*)?\)|} ;

## Function definition
# $1 : return list; $2 : function name; $3 : arg list.
$defun_re = qr{^\s*function\s+${retl_re}\s*${var_re}${argl_re}} ;
$defun_rx = qr{^\s*function\s+(${retl_re})\s*(${var_rx})(${argl_re})} ;
## Two quoting chars
$qch2_re = qr{\\\\} ;

## Quotes next character
$qch_re = qr{\\${qch2_re}*} ;

## String
$str_re = qr{\'(?:[^'\n]|(?<!\\)${qch2_re}+\')*\'|\"(?:[^"\n]|(?<!\\)${qch2_re}+\")*\"} ;
$str_rx = qr{(\'(?:[^'\n]|(?<!\\)${qch2_re}+\')*\'|\"(?:[^"\n]|(?<!\\)${qch2_re}+\")*\")} ;

## Parenthesis "
$oppar = qr{[\(\{\[]};
$noppar = qr{[^\(\{\[]};
$opparx = qr{([\(\{\[])};

$mcp = {"("=>")", "["=>"]", "{"=>"}"};


## Comments
## Not perfect, but should catch most cases
## $com_re = qr{\#((?:[^'"]|(?<!\\)${qch2_re}*['"])*['"]|.*)} ;

$cch_re = qr{[\#%]+};
$cch_rx = qr{([\#%]+)};

1;

