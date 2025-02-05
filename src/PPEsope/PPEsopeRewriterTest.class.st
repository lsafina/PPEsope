Class {
	#name : #PPEsopeRewriterTest,
	#superclass : #PPCompositeParserTest,
	#category : #'PPEsope-Tests'
}

{ #category : #tests }
PPEsopeRewriterTest class >> esopeBigFile [
	^ PPEsopeGrammarTest esopeBigFile
]

{ #category : #tests }
PPEsopeRewriterTest class >> esopeBigFileProcessed [
	^ ''
]

{ #category : #tests }
PPEsopeRewriterTest class >> esopeSmallFile [
	^ PPEsopeGrammarTest esopeSmallFile
]

{ #category : #tests }
PPEsopeRewriterTest class >> esopeSmallFileProcessed [
	^ '      subroutine stgbrk(
C     == entrees ==
     & alist,splist,
C     == sorties ==
     & rlist,status)
C xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
Cb  Subroutine : stgbrk (langage Esope)
Cb  Module     : STRING
Cb  Auteur     : L.Brault
Cb  Date       : 28-Octobre-1997
Cb  Service    : EPNC 
Cb  But        : briser/decouper des chaines de caracteres
Cb               d''apres une liste de separateurs
C xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
C
Cae  alist  : "la" liste de chaines
Cae  splist : "la" liste de separateurs
C
Cas  rlist  : la liste des morceaux/decoupes de "la" chaine
Cas  status : status d''execution (status=0 <=> succes)
C
C
C Fichier a inclure dans tout source PACOME, ESOPE ou FORTRAN.
C
C Utilisation lors de la compilation :
C
C source Fortran :
C  f77 -Dfortran -c -I{repertoires d''inclusion} fichier.F
C
C source Esope :
C  cpp -P -I{repertoires d''inclusion} fichier.E > fichier.e
C
C source Fortran et Esope pour le Cray :
C  cpp -Dcray -I{repertoires d''inclusion} fichier.[F,E] > fichier_source_cray
C
C  Auteur  : L.Caramelle
C  Service : Serlog Systemes.
C  Date    : 28/03/93.
C
C
C  Modif   : G.Martinez
C  Service : EPNC.
C  Date    : 24/08/95.
C  Sujet   : Portage sur CRAY.
C
C  Modif   : M.PONCE
C            (origine L.BRAULT)
C  Service : EPDN
C  Date    : 19/07/2000
C  Sujet   : IMPLICIT_H_INCLUDED
C


      implicit logical (a-z)

C
C >> verifier que cette implementation est compatible 
C >> avec celle du type CHAINE de GIBIANE/ACROPOL
C 
C lstg : longueur de la chaine de caractere
C cstg : les caracteres de la chaine
C
C PROPRIETE: lstg >= 0
C
      integer lstg
cESO  segment string
cESO    character cstg*(lstg)
cESO  endsegment
C
C nlist : capacite de la liste
C ilist : taille   de la liste
C
C PROPRIETE: 0<= ilist <= nlist
C
      integer nlist
cESO  segment,list
cESO    integer ilist
cESO    integer elist(nlist)
cESO  endsegment
C
cESO  pointeur alist.list
cESO  pointeur splist.list
cESO  pointeur rlist.list
      integer  status
C
cESO  pointeur xs.string
cESO  pointeur sp.string
cESO  pointeur ms.string
      integer  lxs
      integer  lsp
      integer  lmin
      integer  i,ia
      integer  idx,kdx
      integer  first,last
      integer  mfirst,mlast
C
      status=0
      nlist=10
cESO  segini,rlist
      ESOat(rlist,ilist)=0
C
cESO  segact,splist
cESO  segact,alist
C
C     //repeter "decouper chaque chaine"
      do ia=1,ESOat(alist,ilist)
        xs=abs(ESOar(ESOat(alist,elist),ia))
C
cESO    segact,xs
        lxs=ESOsl(ESOat(xs,cstg),1)
C
        if(lxs.eq.0)then
C         == la chaine a "decouper" est vide
C         >> ne rien renvoyer <<
        else
C         == la chaine a "decouper" n''est pas vide 
          first=1
          last=lxs
C
C         //repeter "decouper morceau"
 100      continue
C
C           //repeter "sauter separateur-tete"
C             -- chercher separateur-entete
C             -- ... donnant le plus petit separateur
 110          i=0
              lmin=-1
 120          i=i+1
              if(i.le.(ESOat(splist,ilist)))then
                sp=abs(ESOar(ESOat(splist,elist),i))
cESO            segact,sp
                lsp=ESOsl(ESOat(sp,cstg),1)
                if(lsp.eq.0)then
                  idx=1
                else
                  idx=index(ESOat(xs,cstg)(first:last),
     +                      ESOat(sp,cstg))
                endif
                if(idx.eq.1) then
C                 -- initialiser
                  if(lmin.eq.-1)lmin=lsp
C                 -- favoriser tout separateur-non-vide
                  if(lmin.eq.0)lmin=lsp
C                 -- prendre le plus petit separateur-non-vide
                  if((lsp.lt.lmin).and.(lsp.gt.0))lmin=lsp
                endif
cESO            segdes,sp
                goto 120
              endif
C
C             //si trouve, sauter separateur-tete
              if(lmin.ne.-1) then
C               -- sauter separateur-entete
                first=first+lmin
C               //si possible, sauter prochain separateur-tete
                if((first.le.last).and.(lmin.ge.1))goto 110
              endif
C           //fin repeter "sauter separateur-tete"
C
C           //si possible, chercher morceau
            if(first.le.last)then
C             -- chercher separateur-morceau
C             -- ... donnant le plus petit morceau
              i=0
              kdx=0
              lmin=-1
 130          i=i+1
              if(i.le.(ESOat(splist,ilist)))then
                sp=abs(ESOar(ESOat(splist,elist),i))
cESO            segact,sp
                lsp=ESOsl(ESOat(sp,cstg),1)
                if(lsp.eq.0)then
                  idx=1
                else
                  idx=index(ESOat(xs,cstg)(first:last),
     +                      ESOat(sp,cstg))
                endif
                if(idx.ne.0) then
                  if(kdx.eq.0)then
                    kdx=idx
                    lmin=lsp
                  endif
                  if(idx.lt.kdx)then
                    kdx=idx
                    lmin=lsp
                  endif
                  if((idx.eq.kdx).and.(lsp.lt.lmin))then
                    kdx=idx
                    lmin=lsp
                  endif
                endif
cESO            segdes,sp
                goto 130
              endif
C
C             -- determiner limites morceau
              if(kdx.ne.0) then
                mfirst=first
                if(kdx.eq.1)then
                  mlast=first
                else
                  mlast=first+kdx-2
                endif
              else
                lmin=0
                mfirst=first
                mlast=last
              endif
C
C             -- ranger morceau 
              lstg=mlast-mfirst+1
cESO          segini,ms
                ESOat(ms,cstg)=ESOat(xs,cstg)(mfirst:mlast)
cESO          segdes,ms
              ESOat(rlist,ilist)=ESOat(rlist,ilist)+1
              if((ESOat(rlist,ilist)).gt.nlist)then
                nlist=nlist+10
cESO            segadj,rlist
              endif
              ESOar(ESOat(rlist,elist),ESOat(rlist,ilist))=ms          
C
C             //si possible, decouper prochain morceau
              first=mlast+lmin+1
              if(first.le.last)goto 100
            endif
C
C         //fin repeter "decouper morceau"
        endif
C
cESO    segdes,xs
      enddo
C     //fin repeter "decouper chaque chaine"
C
cESO  segdes,alist
cESO  segdes,splist
cESO  segdes,rlist
      return
      end
'
]

{ #category : #accessing }
PPEsopeRewriterTest >> parserClass [
	^ PPEsopeRewriter 
]

{ #category : #running }
PPEsopeRewriterTest >> setUp [
	super setUp.
	parser initStream.
]

{ #category : #accessing }
PPEsopeRewriterTest >> testFortranLine [
	| sourcecode |
	sourcecode := '      subroutine test(brr)
'.
	self parse: sourcecode rule: #fortranLine.

	self assert: parser output equals: sourcecode
]

{ #category : #accessing }
PPEsopeRewriterTest >> testFortranLineEsoAt [
	self parse: '      rlist.ilist=0
' rule: #fortranLine.
	self assert: parser output equals: '      ESOat(rlist,ilist)=0
'
]

{ #category : #accessing }
PPEsopeRewriterTest >> testFortranLineEsoSlash [
	self
		parse:
			'        lxs=xs.cstg(/1)
'
		rule: #fortranLine.
	self
		assert: parser output
		equals:
			'        lxs=ESOsl(ESOat(xs,cstg),1)
'
]

{ #category : #accessing }
PPEsopeRewriterTest >> testPointer [
	| sourcecode |
	sourcecode := 'pointeur splist.list
'.
	self parse: '      ' , sourcecode rule: #pointer.
	self assert: parser output equals: 'cESO  ' , sourcecode
]

{ #category : #accessing }
PPEsopeRewriterTest >> testSegact [
	| sourcecode |
	sourcecode := 'segact,splist
'.
	self parse: '      ' , sourcecode rule: #segact.
	self assert: parser output equals: 'cESO  ' , sourcecode
]

{ #category : #accessing }
PPEsopeRewriterTest >> testSegactWithSpaces [
	| sourcecode |
	
	sourcecode := '  segact,xs
'.
	self parse: '      ' , sourcecode rule: #segact.
	self assert: parser output equals: 'cESO  ' , sourcecode
]

{ #category : #accessing }
PPEsopeRewriterTest >> testSegadj [
	| sourcecode |
	sourcecode := 'segadj,aplist
'.
	self parse: '      ' , sourcecode rule: #segadj.
	self assert: parser output equals: 'cESO  ' , sourcecode
]

{ #category : #accessing }
PPEsopeRewriterTest >> testSegdef [
	| finalcode sourcecode |
	sourcecode := '      segment,values
        character*8        valtyp
        real               valf(valnf)
        integer            vale(valne)
      endsegment
'.
	finalcode := 'cESO  segment,values
cESO    character*8        valtyp
cESO    real               valf(valnf)
cESO    integer            vale(valne)
cESO  endsegment
'.
	self parse: sourcecode rule: #segdef.
	self assert: parser output equals: finalcode.
]

{ #category : #accessing }
PPEsopeRewriterTest >> testSegdes [
	| sourcecode |
	sourcecode := 'segdes,alist
'.
	self parse: '      ' , sourcecode rule: #segdes.
	self assert: parser output equals: 'cESO  ' , sourcecode
]

{ #category : #accessing }
PPEsopeRewriterTest >> testSegini [
	| sourcecode |
	sourcecode := 'segini,rlist
'.
	self parse: '      ' , sourcecode rule: #segini.
	self assert: parser output equals: 'cESO  ' , sourcecode
]

{ #category : #accessing }
PPEsopeRewriterTest >> testSegsup [
	| sourcecode |
	sourcecode := 'segsup,rlist
'.
	self parse: '      ' , sourcecode rule: #segsup.
	self assert: parser output equals: 'cESO  ' , sourcecode
]

{ #category : #accessing }
PPEsopeRewriterTest >> testSmallFile [
	self parse: self class esopeSmallFile rule: #start.
	self assert: parser output equals: self class esopeSmallFileProcessed
]

{ #category : #accessing }
PPEsopeRewriterTest >> testTranslateEsopeArray [
	self
		assert:
			(parser translateEsopeAt: (parser translateEsopeArray: 'ab.cd(ef)'))
		equals: 'ESOar(ESOat(ab,cd),ef)'
]

{ #category : #accessing }
PPEsopeRewriterTest >> testTranslateEsopeArrayDotInsidePar [
	self
		assert: (parser translateEsopeAt: (parser translateEsopeArray: 'rlist.elist(rlist.ilist)=ms'))
		equals: 'ESOar(ESOat(rlist,elist),ESOat(rlist,ilist))=ms'
]

{ #category : #accessing }
PPEsopeRewriterTest >> testTranslateEsopeAtBinaryOperator [
	self
		assert: (parser translateEsopeAt: '         if(lxs.eq.0)then')
		equals: '         if(lxs.eq.0)then'.
	self
		assert:
			(parser
				translateEsopeAt: '              if((rlist.ilist).gt.nlist)then')
		equals: '              if((ESOat(rlist,ilist)).gt.nlist)then'
]

{ #category : #accessing }
PPEsopeRewriterTest >> testTranslateEsopeAtEqOperator [
	self assert: (parser translateEsopeAt: '         if(lxs.eq.0)then') equals: '         if(lxs.eq.0)then'
]

{ #category : #accessing }
PPEsopeRewriterTest >> testTranslateEsopeAtNoDot [
	self assert: (parser translateEsopeAt: 'abc') equals: 'abc'
]

{ #category : #accessing }
PPEsopeRewriterTest >> testTranslateEsopeAtOneDot [
	self
		assert: (parser translateEsopeAt: 'abc.def')
		equals: 'ESOat(abc,def)'
]

{ #category : #accessing }
PPEsopeRewriterTest >> testTranslateEsopeAtTwoDots [
	self
		assert: (parser translateEsopeAt: 'abc.def=opq.xyz')
		equals: 'ESOat(abc,def)=ESOat(opq,xyz)'
]

{ #category : #accessing }
PPEsopeRewriterTest >> testTranslateEsopeSlashEsopeAt [
	self
		assert:
			(parser
				translateEsopeAt: (parser translateEsopeSlash: 'abc.def(/1)'))
	
		equals: 'ESOsl(ESOat(abc,def),1)'
]

{ #category : #accessing }
PPEsopeRewriterTest >> testTranslateEsopeSlashNone [
	self
		assert: (parser translateEsopeSlash: 'abc.def')
		equals: 'abc.def'
]

{ #category : #accessing }
PPEsopeRewriterTest >> testTranslateEsopeSlashOne [
	self
		assert: (parser translateEsopeSlash: 'abc.def(/1)')
		equals: 'ESOsl(abc.def,1)'
]

{ #category : #accessing }
PPEsopeRewriterTest >> testTranslateEsopeSlashSlash [
	self
		assert: (parser translateEsopeAt: 'C     //fin repeter "decouper chaque chaine"')
		equals: 'C     //fin repeter "decouper chaque chaine"'
]
