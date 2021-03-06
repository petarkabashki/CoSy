| CoSy refcounted list parameter passing based on Stack Frames |

cr ." | ParameterPushing > " 
| |\/| StackFrames |\/| ================================== \/ |  
." |\\/| StackFrames |\\/| "  
 
| Implementing the notion in George B. Lyons : Stack Frames and Local Variables : http://dl.forth.com/jfar/vol3/no1/article3.pdf
| was http://www.forth.com/archive/jfar/vol3/no1/article3.pdf
 
 s0 cell- dup constant s1 dup dup !  variable, SFptr 	 	
 | relies for stopping on the 0th stack cell being set to itself 
	| initialize StackFrame pointer 
| SFptr @ dup @ !
  
: reset prior reset s1 SFptr ! ;
 
: SF+ | puts previous esi on the stack and saves current 
	  esi@ cell- SFptr xchg ;
 
: SFx cells SFptr @ + ; 	| ( n -- n ofset by current pointer ) 
 
: SF@ SFx @ ;  	: SF! SFx ! ;  | Fetch and store relative to current pointer
 
: SF- | ( ... n -- drop n ) restores previous stack pointer but just drop n items beyond current pointer .
	>aux SFptr @ dup @ SFptr ! cell+ esi! aux> ndrop ; 

| of ?able worth
| : SF_ ( res -- res ) >r 0 SF@ dup @ SFptr !   esi! r> ;
| : SF- | restores previous stack pointer .
|   SFptr @ @ dup s0 =if drop ( ." s0 " cr ) s0 dup SFptr ! cell- esi! ;then 
|     dup SFptr ! esi! ; 

| : SFn ( -- n ) SFptr @ dup @ swap - cells/ - ;  | number of parameters in frame
	| undefined for empty stack .

: RA  1 SFx ;	: LA  2 SFx ;	| Shorthand for dyadic fns .
: R@  1 SF@ ;	: L@  2 SF@ ;
: R!  1 SF! ;	: L!  2 SF! ;
 
: LR@ 2 SF@ 1 SF@ ;

| The stack just above the SF pointer can be used as locals which will of course
| be dropped along with the frame . Note these ' l functions are naked . 
| To use , values must be pushed on the stack ,  and if a CoSy object
| appropriate ref handling must be done .

: l0 -1 SFx ; 	: l0@ -1 SF@ ; 	: l0! -1 SF! ; 
: l1 -2 SFx ; 	: l1@ -2 SF@ ; 	: l1! -2 SF! ; 

." |/\\| StackFrames |/\\| "  

| \/ \/ | PARAMETER PUSHING & POPPING | \/ \/ |

| Aux stack fns w ref accounting .
: >a> : >aux+> dup : >a : >aux+ refs+> >aux ;
: a> : aux-ok> aux> dup refs-ok ;
: a- : aux- aux> refs- ; 
: a@ aux@ ;						| added 20181231
: /\a refs+> (aux) @ dup @ refs- ! ; 	| like >t0 . replaces value handles ref count . 

: 1p ( RA -- ) | pushs 1 arg from stack to param stack and ref incs .
	| use on entrance to 1 arg fn .
	SF+ R@ refs+ ;
 
: 1p> ( RA -- ) | pushs 1 arg from stack to param stack and ref incs .
	| use on entrance to 1 arg fn .
	SF+ R@ refs+> ;

: 1P ( -- )	| decrements refs and clears param stack . Use leaving 1 arg fn .  
	R@ refs- 1 SF- ;
 
: 1P_> ( r -- r )  >aux 1P aux> ;
 
: 1P> ( r -- r )  >aux+ 1P aux-ok> ;

: 2p ( LA RA -- ) | pushs 2 args from stack to param stack 
	| and ref incs . Use on entrance to 2 arg fn .
	SF+ LR@ 2refs+ ;
 
: 2p> ( LA RA -- LA RA ) | pushs 2 args from stack to param stack 
	| and ref incs . Use on entrance to 2 arg fn .
	SF+ LR@ 2refs+> ;

: 2P ( -- )	| decrements refs and clears param stack . Use leaving 2 arg fn .  
	RA 2@ 2refs- 2 SF- ;
 
: 2P_> >aux 2P aux> ; 
 
: 2P> >aux+> 2P aux-ok> ; 

| /\ /\ | PARAMETER PUSHING & POPPING | /\ /\ | 
." < ParameterPushing | " cr 