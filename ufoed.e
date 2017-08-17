/* UFO, ENEMY UNKNOWN Editor v1.0 */
/* Full Distribution Version */

->FOLD -{ HISTORY }-
/*     v1.00 - First Release. (xx/07/95)          */
->FEND

->FOLD -( MODULES )-
MODULE  'gadtools',
        'dos/dos',
        'libraries/gadtools',
        'reqtools',
        'libraries/reqtools',
        'intuition/intuition',
        'intuition/screens',
        'intuition/gadgetclass',
        'graphics/text',
        'exec/memory'
->FEND
->FOLD -( CONST )-
->FEND
->FOLD -( ENUM )-
ENUM
    NONE,
    ER_OPENLIB,
    ER_SCREEN,
    ER_VISUAL,
    ER_CONTEXT,
    ER_GADGET,
    ER_WINDOW,
    ER_FILE,
    ER_ALLOC,
    ER_MENUS,
    ER_TEXT,
    ER_WB,
    ER_PORT   
->FEND
->FOLD -( GLOBAL DEFS )-
DEF     wnd:PTR TO window,
        glist,
        scr:PTR TO screen,
        visual=NIL,
        g:PTR TO gadget,
        g2:PTR TO gadget,
        g4:PTR TO gadget,
        g5:PTR TO gadget,
        g6:PTR TO gadget,
        g7:PTR TO gadget,
        g8:PTR TO gadget,
        g9:PTR TO gadget,
        g10:PTR TO gadget,
        g11:PTR TO gadget,
        g12:PTR TO gadget,
        g13:PTR TO gadget,
        g14:PTR TO gadget,

        g16:PTR TO gadget,
        g17:PTR TO gadget,
        g18:PTR TO gadget,
        g19:PTR TO gadget,
        g20:PTR TO gadget,
        g21:PTR TO gadget,
        g22:PTR TO gadget,
        g23:PTR TO gadget,
        g24:PTR TO gadget,
        g25:PTR TO gadget,
        g26:PTR TO gadget,
        g27:PTR TO gadget,
        g28:PTR TO gadget,
        g29:PTR TO gadget,
        g30:PTR TO gadget,
        g31:PTR TO gadget,

        topaz:PTR TO textattr,
        req:PTR TO rtfilerequester,
        infos=0,type=0,
        mes:PTR TO intuimessage,
        offy,
        mem,
        x=0,
        size,
        marker1[20]:ARRAY OF INT,
        marker2[20]:ARRAY OF INT,
        marker3[20]:ARRAY OF INT
->FEND 

->FOLD -[ main() HANDLE ]-
PROC main() HANDLE

DEF done=FALSE,
    soldier=1

    setup()
    REPEAT
        wait4message(wnd)
        IF infos=1 THEN load()
        IF infos=2 THEN save()
        IF infos=3 THEN done:=TRUE
        IF (infos>3) AND (infos<14) THEN slide(infos,mes.code,soldier)
        IF infos=15 THEN about()
        IF infos=17
            soldier:=mes.code+1
            WriteF('mes:\h\n',mes.code)
            setsoldier(soldier)
        ENDIF
        IF infos=29 THEN help()
    UNTIL done=TRUE
    Raise(NONE)
EXCEPT
    closedown()
    IF exception>0 THEN WriteF('MNVX Standard Error #\s \n',
    ListItem(['000:No Error!',
              '001:OpenLib',
              '002:Screen',
              '003:Visual',
              '004:Context',
              '005:Gadget',
              '006:Window',
              '007:File',
              '008:Alloc',
              '009:Menus',
              '010:Font',
              '011:Workbench'],exception))
ENDPROC
->FEND
->FOLD -[ about() ]-
PROC about()
    showstatus('UFO Ed - cODE: mAFFIA of nERVE aXIS!')
    RtEZRequestA({abouttext},'_oK!',0,0,[RT_UNDERSCORE,"_",
                                         RT_TEXTATTR,topaz])
    showstatus('rEADY')
ENDPROC
->FEND
->FOLD -[ help() ]-
PROC help()
    showstatus('UFO Ed - cODE: mAFFIA of nERVE aXIS!')
    RtEZRequestA({helptext},'_oK!',0,0,[RT_UNDERSCORE,"_",
                                  RT_TEXTATTR,topaz])
    showstatus('rEADY')
ENDPROC
->FEND
->FOLD -[ showstatus(text) ]-
PROC showstatus(text)
        Gt_SetGadgetAttrsA(g18,wnd,NIL,[GTTX_TEXT,text,NIL])
ENDPROC
->FEND  
->FOLD -[ load() ]-
PROC load()

DEF itsname[16]:STRING,
    dafile[120]:STRING,
    buf[120]:STRING,
    check[1]:STRING,
    count,
    info:fileinfoblock,
    read,fhandle,lock,n=0,
    first=0,z=0
    
    FOR n:=0 TO 19 DO marker1[n]:=666
    FOR n:=0 TO 19 DO marker2[n]:=666
    FOR n:=0 TO 19 DO marker3[n]:=666
    showstatus('lOADING "ufo/game_x/soldier.dat" fILE ')
    buf[0]:=0
    itsname:='                          '
    IF RtFileRequestA(req,buf,'sOLDIER.dAT fILE tO lOAD',[RT_TEXTATTR,topaz,
                                                          RT_WINDOW,wnd,
                                                          RTFI_FLAGS,FREQF_PATGAD])
        StrCopy(dafile,req.dir)
        count:=StrLen(dafile)
        StrCopy(itsname,buf,16)
        IF StrCmp(dafile,'')
            StrCopy(dafile,buf)
        ELSE
            IF dafile[count-1]=58
                StrCopy(dafile,req.dir)
                StrAdd(dafile,buf)
            ELSE
                StrCopy(dafile,req.dir)
                StrAdd(dafile,'/',1)
                StrAdd(dafile,buf)
            ENDIF
        ENDIF
        IF mem THEN FreeVec(mem)
        IF (lock:=Lock(dafile,ACCESS_READ))=NIL
                RtEZRequestA(' cOULDNT lOCK sELECTED fILE qUITING oUT','_oK',0,0,[RT_UNDERSCORE,"_",RTEZ_REQTITLE,'WARNING!'])
                Raise(ER_FILE)
        ENDIF
        Examine(lock,info)
        size:=info.size
        UnLock(lock)
        IF (mem:=AllocVec(size,MEMF_PUBLIC))=NIL
                RtEZRequestA(' cOULDN`T aLLOCATE eNOUGH bYTES oF fREE mEMORY \n qUITING oUT','_oK',0,0,[RT_UNDERSCORE,"_",RTEZ_REQTITLE,'WARNING!'])
                Raise(ER_FILE)
        ENDIF
        IF (fhandle:=Open(dafile,MODE_OLDFILE))=NIL
                RtEZRequestA(' cOULDNT oPEN sELECTED fILE qUITING oUT','_oK',0,0,[RT_UNDERSCORE,"_",RTEZ_REQTITLE,'WARNING!'])
                FreeVec(mem)
                Raise(ER_FILE)
        ENDIF
        IF (read:=Read(fhandle,mem,size))=NIL
                RtEZRequestA(' cOULDNT rEAD sELECTED fILE qUITING oUT','_oK',0,0,[RT_UNDERSCORE,"_",RTEZ_REQTITLE,'WARNING!'])
                FreeVec(mem)
                Raise(ER_FILE)
        ENDIF
        x:=0
        z:=0
        showstatus('sCANNING sOLDIER fILE....pLEASE wAIT!')
        FOR n:=1 TO size
            IF (mem[n]=$ff) AND (mem[n+1]=$ff) AND (x<16) AND (mem[n+2]<>$ff) AND (mem[n+3]<>$ff)
                showstatus('fOUND FF mARKER!')
                marker1[x]:=n+1
                REPEAT
                    z++
                    marker2[x]:=z+marker1[x]+10
                UNTIL mem[z+(marker1[x]+10)]=$00
                REPEAT
                    z++
                    marker3[x]:=z+marker1[x]+10
                UNTIL (mem[z+(marker1[x]+10)]=$00) AND (marker2[x] <> marker1[x])
                z:=0
                x++
            ELSEIF (mem[n]=$ff) AND (mem[n+1]=$ff) AND (mem[n+2]=$ff) AND (mem[n+3]=$ff) AND (x<16)
                showstatus('fOUND FFFF mARKER!')
                marker1[x]:=n+3
                REPEAT
                    z++
                    marker2[x]:=z+marker1[x]+10
                UNTIL mem[z+(marker1[x]+10)]=$00
                REPEAT
                    z++
                    marker3[x]:=z+marker1[x]+10
                UNTIL (mem[z+(marker1[x]+10)]=$00) AND (marker2[x] <> marker1[x])
                z:=0
                x++
            ENDIF 
        ENDFOR
        showstatus('sCAN fINISHED....dATA aSSIMILATED!')
        Close(fhandle)
        check:=' '
        n:=0
        setsoldier(1)
        Gt_SetGadgetAttrsA(g2,wnd,NIL,[GA_DISABLED,FALSE,0])
        Gt_SetGadgetAttrsA(g4,wnd,NIL,[GA_DISABLED,FALSE,0])
        Gt_SetGadgetAttrsA(g5,wnd,NIL,[GA_DISABLED,FALSE,0])
        Gt_SetGadgetAttrsA(g6,wnd,NIL,[GA_DISABLED,FALSE,0])
->        Gt_SetGadgetAttrsA(g7,wnd,NIL,[GA_DISABLED,FALSE,0])
        Gt_SetGadgetAttrsA(g8,wnd,NIL,[GA_DISABLED,FALSE,0])
->        Gt_SetGadgetAttrsA(g9,wnd,NIL,[GA_DISABLED,FALSE,0])
->        Gt_SetGadgetAttrsA(g10,wnd,NIL,[GA_DISABLED,FALSE,0])
->        Gt_SetGadgetAttrsA(g11,wnd,NIL,[GA_DISABLED,FALSE,0])
        Gt_SetGadgetAttrsA(g12,wnd,NIL,[GA_DISABLED,FALSE,0])
        Gt_SetGadgetAttrsA(g13,wnd,NIL,[GA_DISABLED,FALSE,0])

        Gt_SetGadgetAttrsA(g14,wnd,NIL,[GA_DISABLED,FALSE,0])
        Gt_SetGadgetAttrsA(g17,wnd,NIL,[GA_DISABLED,FALSE,0])
        Gt_SetGadgetAttrsA(g30,wnd,NIL,[GA_DISABLED,FALSE,0])
        Gt_SetGadgetAttrsA(g31,wnd,NIL,[GA_DISABLED,FALSE,0])

        showstatus(' lOAD cOMPLETE - nO pROBS :)')
    ELSE
        showstatus('  nO fILE sELECTED :(')
    ENDIF   
    FOR n:=0 TO 10 DO WriteF(':\z\h[3]',marker1[n])
    WriteF('\n')
    FOR n:=0 TO 10 DO WriteF(':\z\h[3]',marker2[n])
    WriteF('\n')
    FOR n:=0 TO 10 DO WriteF(':\z\h[3]',marker3[n])
    WriteF('\n')
ENDPROC   
->FEND
->FOLD -[ setsoldier(which) ]-
PROC setsoldier(which)
DEF temp[20]:STRING
    Gt_SetGadgetAttrsA(g4,wnd,NIL,[GTSL_LEVEL,mem[marker3[which]+1],0])
    Gt_SetGadgetAttrsA(g5,wnd,NIL,[GTSL_LEVEL,mem[marker3[which]+3],0])
    Gt_SetGadgetAttrsA(g6,wnd,NIL,[GTSL_LEVEL,mem[marker3[which]+2],0])
->    Gt_SetGadgetAttrsA(g7,wnd,NIL,[GTSL_LEVEL,mem[],0])
    Gt_SetGadgetAttrsA(g8,wnd,NIL,[GTSL_LEVEL,mem[marker3[which]+4],0])
->    Gt_SetGadgetAttrsA(g9,wnd,NIL,[GTSL_LEVEL,mem[],0])
->    Gt_SetGadgetAttrsA(g10,wnd,NIL,[GTSL_LEVEL,mem[],0])
->    Gt_SetGadgetAttrsA(g11,wnd,NIL,[GTSL_LEVEL,mem[],0])
    Gt_SetGadgetAttrsA(g12,wnd,NIL,[GTSL_LEVEL,mem[marker1[which]+4],0])
    Gt_SetGadgetAttrsA(g13,wnd,NIL,[GTSL_LEVEL,mem[marker1[which]+2],0])
    StrCopy(temp,(mem+marker1[which])+9,(marker1[which]+9)-marker2[which])
    Gt_SetGadgetAttrsA(g16,wnd,NIL,[GTTX_TEXT,temp,NIL])
/*
        WriteF('marker:\h\n',marker1[which])
        WriteF('value.:\h\n',mem[(marker1[which])+2])
*/
    slide(4,mem[marker3[which]+1],1)
    slide(5,mem[marker3[which]+3],1)
    slide(6,mem[marker3[which]+2],1)
->    slide(7,mem[],1)
    slide(8,mem[marker3[which]+4],1)
->    slide(9,mem[],1)
->    slide(10,mem[],1)
->    slide(11,mem[],1)
    slide(12,mem[marker1[which]+4],1)
    slide(13,mem[marker1[which]+2],1)
ENDPROC
->FEND
->FOLD -[ slide(gad,ammount,which) ]-
PROC slide(gad,ammount,which)
DEF temp[20]:STRING

    StringF(temp,'# $\z\h[2]',ammount)
    gad:=gad+15
    IF gad=19
        Gt_SetGadgetAttrsA(g19,wnd,NIL,[GTTX_TEXT,temp,0])
        mem[marker3[which]+1]:=ammount
    ELSEIF gad=20
        Gt_SetGadgetAttrsA(g20,wnd,NIL,[GTTX_TEXT,temp,0])
        mem[marker3[which]+3]:=ammount
    ELSEIF gad=21
        Gt_SetGadgetAttrsA(g21,wnd,NIL,[GTTX_TEXT,temp,0])
        mem[marker3[which]+2]:=ammount
    ELSEIF gad=22
->        Gt_SetGadgetAttrsA(g22,wnd,NIL,[GTTX_TEXT,temp,0])
->        mem[x+8]:=ammount
    ELSEIF gad=23
        Gt_SetGadgetAttrsA(g23,wnd,NIL,[GTTX_TEXT,temp,0])
        mem[marker3[which]+4]:=ammount
    ELSEIF gad=24
->        Gt_SetGadgetAttrsA(g24,wnd,NIL,[GTTX_TEXT,temp,0])
->        mem[x+12]:=ammount
    ELSEIF gad=25
->        Gt_SetGadgetAttrsA(g25,wnd,NIL,[GTTX_TEXT,temp,0])
->        mem[x+14]:=ammount
    ELSEIF gad=26
->        Gt_SetGadgetAttrsA(g26,wnd,NIL,[GTTX_TEXT,temp,0])
->        mem[x+16]:=ammount
    ELSEIF gad=27
        Gt_SetGadgetAttrsA(g27,wnd,NIL,[GTTX_TEXT,temp,0])
        mem[marker1[1]+4]:=ammount
    ELSEIF gad=28
        Gt_SetGadgetAttrsA(g28,wnd,NIL,[GTTX_TEXT,temp,0])
        mem[marker1[1]+2]:=ammount
    ENDIF
ENDPROC
->FEND
->FOLD -[ save() ]-
PROC save()

DEF outfile,
    dafile[120]:STRING,
    buf[120]:STRING,
    count=0

    showstatus('sAVING oUT cAR')
    IF RtFileRequestA(req,buf,'"sOLDIER.dAT" fILE tO sAVE ',[RT_TEXTATTR,topaz,
                                                               RT_WINDOW,wnd])
        StrCopy(dafile,req.dir)
        count:=StrLen(dafile)
        IF StrCmp(dafile,'')
            StrCopy(dafile,buf)
        ELSE
            IF dafile[count-1]=58
                StrCopy(dafile,req.dir)
                StrAdd(dafile,buf)
            ELSE
                StrCopy(dafile,req.dir)
                StrAdd(dafile,'/',1)
                StrAdd(dafile,buf)
            ENDIF
        ENDIF
        IF (outfile:=Open(dafile,MODE_NEWFILE))=NIL THEN Raise(ER_FILE)
        Write(outfile,mem,size)
        Close(outfile)
        showstatus('sAVE oK! nO pROBS :)')
    ELSE
        showstatus('fILE nOT sAVED! :( ')
    ENDIF
ENDPROC
->FEND
->FOLD -[ setup() ]-
PROC setup()
    IF (topaz:=['topaz.font',8,0,FPF_ROMFONT]:textattr)=NIL THEN Raise(ER_TEXT)
    IF (gadtoolsbase:=OpenLibrary('gadtools.library',37))=NIL THEN Raise(ER_OPENLIB)
    IF (reqtoolsbase:=OpenLibrary('reqtools.library',37))=NIL THEN Raise(ER_OPENLIB)
    IF (req:=RtAllocRequestA(req,0))=NIL THEN Raise(ER_ALLOC)
    IF (scr:=LockPubScreen('Workbench'))=NIL THEN Raise(ER_WB)
    IF (visual:=GetVisualInfoA(scr,NIL))=NIL THEN Raise(ER_VISUAL)
    offy:=scr.wbortop+Int(scr.rastport+58)-10
    IF (g:=CreateContext({glist}))=NIL THEN Raise(ER_CONTEXT)

/*
GADGET LIST
 1 -     - BUTTON   - lOAD "soldier.dat" fILE
 2 -  g2 - BUTTON   - sAVE "soldier.dat" fILE
 3 -     - BUTTON   - »»»» qUIT ««««
 4 -  g4 - SLIDER   - tIME uNITS....   - OFFSET:  1 m3
 5 -  g5 - SLIDER   - sTAMINA.......           :  3 m3
 6 -  g6 - SLIDER   - hEALTH........           :  2 m3
 7 -  g7 - SLIDER   - bRAVERY.......           :
 8 -  g8 - SLIDER   - rEACTIONS.....           :  4 m3
 9 -  g9 - SLIDER   - fIRE aCCURACY.           :
10 - g10 - SLIDER   - tHROW aCCURACY           :
11 - g11 - SLIDER   - sTRENGTH......           :
12 - g12 - SLIDER   - kILLS.........           :  4 m
13 - g13 - SLIDER   - miSSIONS......           :  2 m
14 - g14 - CYCLE    - gENDER
15 -     - BUTTON   - aBOUT
16 - g16 - TEXT     - nAME
17 - g17 - CYCLE    - sOLDIER
18 - g18 - TEXT     - { STATUS }
19 - g19 - TEXT     - #
20 - g20 - TEXT     - #
21 - g21 - TEXT     - #
22 - g22 - TEXT     - #
23 - g23 - TEXT     - #
24 - g24 - TEXT     - #
25 - g25 - TEXT     - #
26 - g26 - TEXT     - #
27 - g27 - TEXT     - #
28 - g28 - TEXT     - #
29 -     - BUTTON   - hELP
30 - g30 - CYCLE    - rANK
31 - g31 - CYCLE    - aRMOUR
*/


    IF (g:=CreateGadgetA(BUTTON_KIND,g,[5,5,200,15,'lOAD "soldier.dat" fILE',topaz,1,16,visual,1]:newgadget,
        [NIL]))=NIL THEN Raise(ER_GADGET)
    IF (g:=g2:=CreateGadgetA(BUTTON_KIND,g,[5,20,200,15,'sAVE "soldier.dat" fILE',topaz,2,16,visual,1]:newgadget,
        [GA_DISABLED,TRUE,NIL]))=NIL THEN Raise(ER_GADGET)
    IF (g:=CreateGadgetA(BUTTON_KIND,g,[5,35,335,15,'»»»» qUIT ««««',topaz,3,16,visual,1]:newgadget,
        [NIL]))=NIL THEN Raise(ER_GADGET)
    IF (g:=g4:=CreateGadgetA(SLIDER_KIND,g,[15,75,200,10,'tIME uNITS....',topaz,4,2,visual,0]:newgadget,
        [GTSL_MIN,0,
         GTSL_MAX,$FF,
         GTSL_LEVEL,0,
         PGA_FREEDOM,LORIENT_HORIZ,
         GA_IMMEDIATE,TRUE,
         GA_RELVERIFY,TRUE,
         GA_DISABLED,TRUE,0]))=NIL THEN Raise(ER_GADGET)
    IF (g:=g5:=CreateGadgetA(SLIDER_KIND,g,[15,85,200,10,'sTAMINA.......',topaz,5,2,visual,0]:newgadget,
        [GTSL_MIN,0,
         GTSL_MAX,$FF,
         GTSL_LEVEL,0,
         PGA_FREEDOM,LORIENT_HORIZ,
         GA_IMMEDIATE,TRUE,
         GA_RELVERIFY,TRUE,
         GA_DISABLED,TRUE,0]))=NIL THEN Raise(ER_GADGET)
    IF (g:=g6:=CreateGadgetA(SLIDER_KIND,g,[15,95,200,10,'hEALTH........',topaz,6,2,visual,0]:newgadget,
        [GTSL_MIN,0,
         GTSL_MAX,$FF,
         GTSL_LEVEL,0,
         PGA_FREEDOM,LORIENT_HORIZ,
         GA_IMMEDIATE,TRUE,
         GA_RELVERIFY,TRUE,
         GA_DISABLED,TRUE,0]))=NIL THEN Raise(ER_GADGET)
    IF (g:=g7:=CreateGadgetA(SLIDER_KIND,g,[15,105,200,10,'bRAVERY.......',topaz,7,2,visual,0]:newgadget,
        [GTSL_MIN,0,
         GTSL_MAX,$FF,
         GTSL_LEVEL,0,
         PGA_FREEDOM,LORIENT_HORIZ,
         GA_IMMEDIATE,TRUE,
         GA_RELVERIFY,TRUE,
         GA_DISABLED,TRUE,0]))=NIL THEN Raise(ER_GADGET)
    IF (g:=g8:=CreateGadgetA(SLIDER_KIND,g,[15,115,200,10,'rEACTIONS.....',topaz,8,2,visual,0]:newgadget,
        [GTSL_MIN,0,
         GTSL_MAX,$FF,
         GTSL_LEVEL,0,
         PGA_FREEDOM,LORIENT_HORIZ,
         GA_IMMEDIATE,TRUE,
         GA_RELVERIFY,TRUE,
         GA_DISABLED,TRUE,0]))=NIL THEN Raise(ER_GADGET)
    IF (g:=g9:=CreateGadgetA(SLIDER_KIND,g,[15,125,200,10,'fIRE aCCURACY.',topaz,9,2,visual,0]:newgadget,
        [GTSL_MIN,0,
         GTSL_MAX,$FF,
         GTSL_LEVEL,0,
         PGA_FREEDOM,LORIENT_HORIZ,
         GA_IMMEDIATE,TRUE,
         GA_RELVERIFY,TRUE,
         GA_DISABLED,TRUE,0]))=NIL THEN Raise(ER_GADGET)
    IF (g:=g10:=CreateGadgetA(SLIDER_KIND,g,[15,135,200,10,'tHROW aCCURACY',topaz,10,2,visual,0]:newgadget,
        [GTSL_MIN,0,
         GTSL_MAX,$FF,
         GTSL_LEVEL,0,
         PGA_FREEDOM,LORIENT_HORIZ,
         GA_IMMEDIATE,TRUE,
         GA_RELVERIFY,TRUE,
         GA_DISABLED,TRUE,0]))=NIL THEN Raise(ER_GADGET)
    IF (g:=g11:=CreateGadgetA(SLIDER_KIND,g,[15,145,200,10,'sTRENGTH......',topaz,11,2,visual,0]:newgadget,
        [GTSL_MIN,0,
         GTSL_MAX,$FF,
         GTSL_LEVEL,0,
         PGA_FREEDOM,LORIENT_HORIZ,
         GA_IMMEDIATE,TRUE,
         GA_RELVERIFY,TRUE,
         GA_DISABLED,TRUE,0]))=NIL THEN Raise(ER_GADGET)
    IF (g:=g12:=CreateGadgetA(SLIDER_KIND,g,[15,155,200,10,'kILLS.........',topaz,12,2,visual,0]:newgadget,
        [GTSL_MIN,0,
         GTSL_MAX,$FF,
         GTSL_LEVEL,0,
         PGA_FREEDOM,LORIENT_HORIZ,
         GA_IMMEDIATE,TRUE,
         GA_RELVERIFY,TRUE,
         GA_DISABLED,TRUE,0]))=NIL THEN Raise(ER_GADGET)
    IF (g:=g13:=CreateGadgetA(SLIDER_KIND,g,[15,165,200,10,'mISSIONS......',topaz,13,2,visual,0]:newgadget,
        [GTSL_MIN,0,
         GTSL_MAX,$FF,
         GTSL_LEVEL,0,
         PGA_FREEDOM,LORIENT_HORIZ,
         GA_IMMEDIATE,TRUE,
         GA_RELVERIFY,TRUE,
         GA_DISABLED,TRUE,0]))=NIL THEN Raise(ER_GADGET)
    IF (g:=g14:=CreateGadgetA(CYCLE_KIND,g,[500,75,100,15,'gENDER',topaz,14,1,visual,0]:newgadget,
        [GTCY_LABELS,['mALE','fEMALE',0],GA_DISABLED,TRUE,NIL]))=NIL THEN Raise(ER_GADGET)
    IF (g:=CreateGadgetA(BUTTON_KIND,g,[205,5,135,15,'aBOUT',topaz,15,16,visual,1]:newgadget,
        [NIL]))=NIL THEN Raise(ER_GADGET)
    IF (g:=g16:=CreateGadgetA(TEXT_KIND,g,[15,180,250,15,'nAME',topaz,16,2,visual,0]:newgadget,
        [GTTX_TEXT,'nONE',
         GTTX_BORDER,1,
         GA_DISABLED,TRUE,NIL]))=NIL THEN Raise(ER_GADGET)
    IF (g:=g17:=CreateGadgetA(CYCLE_KIND,g,[15,55,600,15,'',topaz,17,1,visual,0]:newgadget,
        [GTCY_LABELS,['sOLDIER 1',
                      'sOLDIER 2',
                      'sOLDIER 3',
                      'sOLDIER 4',
                      'sOLDIER 5',
                      'sOLDIER 6',
                      'sOLDIER 7',
                      'sOLDIER 8',
                      'sOLDIER 9',
                      'sOLDIER 10',
                      'sOLDIER 11',
                      'sOLDIER 12',
                      'sOLDIER 13',
                      'sOLDIER 14',
                      'sOLDIER 15',0],GA_DISABLED,TRUE,NIL]))=NIL THEN Raise(ER_GADGET)
    IF (g:=g18:=CreateGadgetA(TEXT_KIND,g,[5,215,625,25,NIL,topaz,18,2,visual,0]:newgadget,
        [GTTX_TEXT,'rEADY & wAITTING!',
         GTTX_BORDER,1,
         GTTX_JUSTIFICATION,GTJ_CENTER,NIL]))=NIL THEN Raise(ER_GADGET)
    IF (g:=g19:=CreateGadgetA(TEXT_KIND,g,[345,75,60,10,'',topaz,19,2,visual,0]:newgadget,
        [GTTX_TEXT,'0',
         GTTX_BORDER,1,NIL]))=NIL THEN Raise(ER_GADGET)
    IF (g:=g20:=CreateGadgetA(TEXT_KIND,g,[345,85,60,10,'',topaz,20,2,visual,0]:newgadget,
        [GTTX_TEXT,'0',
         GTTX_BORDER,1,NIL]))=NIL THEN Raise(ER_GADGET)
    IF (g:=g21:=CreateGadgetA(TEXT_KIND,g,[345,95,60,10,'',topaz,21,2,visual,0]:newgadget,
        [GTTX_TEXT,'0',
         GTTX_BORDER,1,NIL]))=NIL THEN Raise(ER_GADGET)
    IF (g:=g22:=CreateGadgetA(TEXT_KIND,g,[345,105,60,10,'',topaz,22,2,visual,0]:newgadget,
        [GTTX_TEXT,'0',
         GTTX_BORDER,1,NIL]))=NIL THEN Raise(ER_GADGET)
    IF (g:=g23:=CreateGadgetA(TEXT_KIND,g,[345,115,60,10,'',topaz,23,2,visual,0]:newgadget,
        [GTTX_TEXT,'0',
         GTTX_BORDER,1,NIL]))=NIL THEN Raise(ER_GADGET)
    IF (g:=g24:=CreateGadgetA(TEXT_KIND,g,[345,125,60,10,'',topaz,24,2,visual,0]:newgadget,
        [GTTX_TEXT,'0',
         GTTX_BORDER,1,NIL]))=NIL THEN Raise(ER_GADGET)
    IF (g:=g25:=CreateGadgetA(TEXT_KIND,g,[345,135,60,10,'',topaz,25,2,visual,0]:newgadget,
        [GTTX_TEXT,'0',
         GTTX_BORDER,1,NIL]))=NIL THEN Raise(ER_GADGET)
    IF (g:=g26:=CreateGadgetA(TEXT_KIND,g,[345,145,60,10,'',topaz,26,2,visual,0]:newgadget,
        [GTTX_TEXT,'0',
         GTTX_BORDER,1,NIL]))=NIL THEN Raise(ER_GADGET)
    IF (g:=g27:=CreateGadgetA(TEXT_KIND,g,[345,155,60,10,'',topaz,27,2,visual,0]:newgadget,
        [GTTX_TEXT,'0',
         GTTX_BORDER,1,NIL]))=NIL THEN Raise(ER_GADGET)
    IF (g:=g28:=CreateGadgetA(TEXT_KIND,g,[345,165,60,10,'',topaz,28,2,visual,0]:newgadget,
        [GTTX_TEXT,'0',
         GTTX_BORDER,1,NIL]))=NIL THEN Raise(ER_GADGET)
    IF (g:=CreateGadgetA(BUTTON_KIND,g,[205,20,135,15,'hELP',topaz,29,16,visual,1]:newgadget,
        [NIL]))=NIL THEN Raise(ER_GADGET)
    IF (g:=g30:=CreateGadgetA(CYCLE_KIND,g,[500,90,100,15,'rANK',topaz,30,1,visual,0]:newgadget,
        [GTCY_LABELS,['rOOKIE',
                      'sQUADIE',
                      'sERGANT',
                      'cAPTIAN',
                      '???????',0],GA_DISABLED,TRUE,NIL]))=NIL THEN Raise(ER_GADGET)
    IF (g:=g31:=CreateGadgetA(CYCLE_KIND,g,[500,105,100,15,'aRMOUR',topaz,31,1,visual,0]:newgadget,
        [GTCY_LABELS,['nONE',
                      'pERSONAL',
                      'pOWERSUIT',
                      '4',
                      '5',0],GA_DISABLED,TRUE,NIL]))=NIL THEN Raise(ER_GADGET)
    IF (wnd:=OpenWindowTagList(NIL,
        [WA_LEFT,           0,
         WA_TOP,            11,
         WA_WIDTH,          640,
         WA_HEIGHT,         256,
         WA_IDCMP,          $24C077E,
         WA_FLAGS,          WFLG_ACTIVATE OR
                            WFLG_DRAGBAR OR
                            WFLG_GIMMEZEROZERO OR
                            WFLG_DEPTHGADGET,
         WA_CUSTOMSCREEN,   scr,
         WA_AUTOADJUST,     1,
         WA_GADGETS,        glist,
         WA_ACTIVATE,       TRUE,
         WA_RMBTRAP,        TRUE,
         WA_SCREENTITLE,    'UFO,ENEMY UNKNOWN EDITOR v1.00 by >Maffia / Nerve Axis<',
         WA_TITLE,          'UFOEd v1.0   NVX Slaps your ugly face once again in ''95',
         NIL]))=NIL THEN Raise(ER_WINDOW)        
    Gt_RefreshWindow(wnd,NIL)
    DrawBevelBoxA(wnd.rport,5,50,625,150,[GT_VISUALINFO,visual])
ENDPROC
->FEND
->FOLD -[ closedown ]-
PROC closedown()
    IF mem THEN FreeVec(mem)
    IF req THEN RtFreeRequest(req)
    IF wnd THEN CloseWindow(wnd)
    IF glist THEN FreeGadgets(glist)
    IF visual THEN FreeVisualInfo(visual)
    IF scr THEN UnlockPubScreen(NIL,scr)
    IF gadtoolsbase THEN CloseLibrary(gadtoolsbase)
    IF reqtoolsbase THEN CloseLibrary(reqtoolsbase)
ENDPROC
->FEND
->FOLD -[ wait4message(winda:PTR TO window) ]-
PROC wait4message(winda:PTR TO window)
  DEF g:PTR TO gadget
  REPEAT
    type:=0
    IF mes:=Gt_GetIMsg(winda.userport)
      type:=mes.class
      IF type=IDCMP_MENUPICK
        infos:=mes.code
      ELSEIF type=IDCMP_RAWKEY
        infos:=mes.code
      ELSEIF type=IDCMP_VANILLAKEY
        infos:=mes.code
      ELSEIF (type=IDCMP_GADGETDOWN) OR (type=IDCMP_GADGETUP)
        g:=mes.iaddress
        infos:=g.gadgetid
      ELSEIF type=IDCMP_REFRESHWINDOW
        Gt_BeginRefresh(winda)
        Gt_EndRefresh(winda,TRUE)
        type:=0
      ELSEIF type<>IDCMP_CLOSEWINDOW
        type:=0
      ENDIF
      Gt_ReplyIMsg(mes)
    ELSE

      Wait(-1)
    ENDIF
  UNTIL type
ENDPROC
->FEND

->FOLD -{ includes }-

abouttext:  INCBIN 'e:ufo/about.txt'
blank:      INCBIN 'e:ufo/blank.txt'
helptext:   INCBIN 'e:ufo/help.txt'
blank:      INCBIN 'e:ufo/blank.txt'

->FEND

CHAR '$VER: UFOEd v1.0 (00.07.95)'
CHAR 'REGISTERD TO MAFFIA OF NERVE AXIS 00000001'
