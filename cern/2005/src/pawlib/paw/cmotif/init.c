/*
 * $Id: init.c,v 1.2 1996/03/12 16:58:51 cremel Exp $
 *
 * $Log: init.c,v $
 * Revision 1.2  1996/03/12 16:58:51  cremel
 * cpp run over the CDFs
 * Add new resource "hbookfile" to specify the extension for HBOOK files.
 * This can now be specify by the user in .Xdefaults, e.g.:
 *
 * Paw++*hbookfile: dat
 *
 * (default is "hbook").
 *
 * Revision 1.1.1.1  1996/03/01 11:38:56  mclareni
 * Paw
 *
 */
#include "paw/pilot.h"
/*CMZ :  2.06/06 10/11/94  16.38.22  by  Fons Rademakers*/
/*-- Author :*/
#include <stdlib.h>
#include <stdio.h>
#include <string.h>
#include <Xm/Xm.h>
#include <Xm/Protocols.h>
#include <X11/Intrinsic.h>
#include <X11/StringDefs.h>
#include <X11/cursorfont.h>


#include "hmotif/pawm.h"

/* paw, browser, graphics and help icon files */

#define browser_width 50
#define browser_height 50
static char browser_bits[] = {
   0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
   0x40, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x60, 0x00, 0x00, 0x00, 0x00,
   0x00, 0x00, 0x38, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x1c, 0x00, 0x00,
   0x00, 0x00, 0x00, 0x00, 0x1e, 0x00, 0x00, 0x3e, 0x60, 0x00, 0x00, 0x1e,
   0x00, 0xc0, 0xff, 0x79, 0x3c, 0x00, 0x0e, 0x00, 0xc0, 0xc1, 0xf9, 0x78,
   0x00, 0x0e, 0x00, 0xc0, 0xc0, 0xd9, 0x60, 0x00, 0x0e, 0x00, 0xc0, 0xc0,
   0xd9, 0x60, 0x00, 0x0e, 0x00, 0xc0, 0xe0, 0xd9, 0x40, 0x00, 0x0e, 0x00,
   0xc0, 0xe0, 0xdd, 0xc1, 0x00, 0x0e, 0x00, 0xc0, 0x61, 0x9c, 0xc1, 0x00,
   0x0e, 0x00, 0xc0, 0x3b, 0x9c, 0xc1, 0x1c, 0x0e, 0x00, 0xc0, 0x1f, 0x8e,
   0xc1, 0x1d, 0x0e, 0x00, 0xc0, 0x00, 0x0e, 0x83, 0x3d, 0x0e, 0x00, 0xc0,
   0x00, 0x8f, 0x83, 0x3d, 0x07, 0x00, 0xc0, 0x00, 0xff, 0x87, 0xef, 0x03,
   0x00, 0xc0, 0x80, 0x7f, 0x07, 0xef, 0x01, 0x00, 0xcc, 0x01, 0x06, 0x0e,
   0xe7, 0x01, 0x00, 0xfc, 0x01, 0x06, 0x1e, 0xc7, 0x00, 0x00, 0xf8, 0x01,
   0x07, 0x1c, 0xc6, 0x00, 0x00, 0xf0, 0x83, 0x07, 0x3c, 0x86, 0x00, 0x00,
   0x80, 0x87, 0x07, 0x7c, 0x04, 0x00, 0x00, 0x00, 0x07, 0x07, 0x00, 0x00,
   0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
   0x00, 0x00, 0x00, 0x00, 0x7c, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0xf6,
   0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0xe6, 0x00, 0x00, 0x00, 0x00, 0x00,
   0x00, 0x76, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x7e, 0x00, 0x00, 0x00,
   0x00, 0x00, 0x00, 0x36, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0xe6, 0x38,
   0x00, 0x00, 0xc7, 0xf3, 0x00, 0xc6, 0x7d, 0x8e, 0x98, 0xed, 0xb7, 0x01,
   0x86, 0xcd, 0xdb, 0x98, 0x20, 0x36, 0x01, 0x86, 0x0d, 0x5b, 0x90, 0x23,
   0x33, 0x00, 0x86, 0x0d, 0x51, 0x10, 0xef, 0x30, 0x00, 0x86, 0x0d, 0x53,
   0x26, 0x6c, 0x30, 0x00, 0xc6, 0x0d, 0xd3, 0x36, 0xcc, 0x36, 0x00, 0xe6,
   0x0c, 0xde, 0x9f, 0x87, 0x33, 0x00, 0xfe, 0x00, 0x80, 0x08, 0x03, 0x00,
   0x00, 0x3e, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
   0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
   0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
   0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
   0x00, 0x00};

#define graphics_width 50
#define graphics_height 50
static char graphics_bits[] = {
   0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
   0x40, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x60, 0x00, 0x00, 0x00, 0x00,
   0x00, 0x00, 0x38, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x1c, 0x00, 0x00,
   0x00, 0x00, 0x00, 0x00, 0x1e, 0x00, 0x00, 0x3e, 0x60, 0x00, 0x00, 0x1e,
   0x00, 0xc0, 0xff, 0x79, 0x3c, 0x00, 0x0e, 0x00, 0xc0, 0xc1, 0xf9, 0x78,
   0x00, 0x0e, 0x00, 0xc0, 0xc0, 0xd9, 0x60, 0x00, 0x0e, 0x00, 0xc0, 0xc0,
   0xd9, 0x60, 0x00, 0x0e, 0x00, 0xc0, 0xe0, 0xd9, 0x40, 0x00, 0x0e, 0x00,
   0xc0, 0xe0, 0xdd, 0xc1, 0x00, 0x0e, 0x00, 0xc0, 0x61, 0x9c, 0xc1, 0x00,
   0x0e, 0x00, 0xc0, 0x3b, 0x9c, 0xc1, 0x1c, 0x0e, 0x00, 0xc0, 0x1f, 0x8e,
   0xc1, 0x1d, 0x0e, 0x00, 0xc0, 0x00, 0x0e, 0x83, 0x3d, 0x0e, 0x00, 0xc0,
   0x00, 0x8f, 0x83, 0x3d, 0x07, 0x00, 0xc0, 0x00, 0xff, 0x87, 0xef, 0x03,
   0x00, 0xc0, 0x80, 0x7f, 0x07, 0xef, 0x01, 0x00, 0xcc, 0x01, 0x06, 0x0e,
   0xe7, 0x01, 0x00, 0xfc, 0x01, 0x06, 0x1e, 0xc7, 0x00, 0x00, 0xf8, 0x01,
   0x07, 0x1c, 0xc6, 0x00, 0x00, 0xf0, 0x83, 0x07, 0x3c, 0x86, 0x00, 0x00,
   0x80, 0x87, 0x07, 0x7c, 0x04, 0x00, 0x00, 0x00, 0x07, 0x07, 0x00, 0x00,
   0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0xe0, 0x01, 0x00,
   0x00, 0x00, 0x00, 0x00, 0xf8, 0x01, 0x00, 0x00, 0x00, 0x00, 0x00, 0x9c,
   0x01, 0x00, 0x00, 0x00, 0x00, 0x00, 0x0e, 0x00, 0x00, 0x10, 0x00, 0x00,
   0x00, 0x06, 0x00, 0x00, 0x30, 0x18, 0x00, 0x00, 0x07, 0x00, 0x00, 0x30,
   0x00, 0xe0, 0x00, 0x03, 0x78, 0x80, 0x33, 0x80, 0xb3, 0x01, 0xe3, 0x5c,
   0x8f, 0xf7, 0xc8, 0x16, 0x01, 0xe3, 0x0d, 0xcd, 0xf6, 0xd9, 0x74, 0x00,
   0xa7, 0x8d, 0xc9, 0x34, 0xd9, 0xe0, 0x00, 0x86, 0x8d, 0xc8, 0x36, 0xdb,
   0x80, 0x01, 0x86, 0x8d, 0xcd, 0x33, 0xdb, 0x80, 0x01, 0x8e, 0x8d, 0xdf,
   0x30, 0xdb, 0x96, 0x01, 0xfc, 0x85, 0xd7, 0x30, 0xd3, 0xf3, 0x00, 0xf8,
   0x00, 0xc0, 0x00, 0x80, 0x71, 0x00, 0x00, 0x00, 0x40, 0x00, 0x00, 0x00,
   0x00, 0x00, 0x00, 0x40, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
   0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
   0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
   0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
   0x00, 0x00};

#define command_width 50
#define command_height 50
static char command_bits[] = {
   0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
   0x40, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x60, 0x00, 0x00, 0x00, 0x00,
   0x00, 0x00, 0x38, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x1c, 0x00, 0x00,
   0x00, 0x00, 0x00, 0x00, 0x1e, 0x00, 0x00, 0x3e, 0x60, 0x00, 0x00, 0x1e,
   0x00, 0xc0, 0xff, 0x79, 0x3c, 0x00, 0x0e, 0x00, 0xc0, 0xc1, 0xf9, 0x78,
   0x00, 0x0e, 0x00, 0xc0, 0xc0, 0xd9, 0x60, 0x00, 0x0e, 0x00, 0xc0, 0xc0,
   0xd9, 0x60, 0x00, 0x0e, 0x00, 0xc0, 0xe0, 0xd9, 0x40, 0x00, 0x0e, 0x00,
   0xc0, 0xe0, 0xdd, 0xc1, 0x00, 0x0e, 0x00, 0xc0, 0x61, 0x9c, 0xc1, 0x00,
   0x0e, 0x00, 0xc0, 0x3b, 0x9c, 0xc1, 0x1c, 0x0e, 0x00, 0xc0, 0x1f, 0x8e,
   0xc1, 0x1d, 0x0e, 0x00, 0xc0, 0x00, 0x0e, 0x83, 0x3d, 0x0e, 0x00, 0xc0,
   0x00, 0x8f, 0x83, 0x3d, 0x07, 0x00, 0xc0, 0x00, 0xff, 0x87, 0xef, 0x03,
   0x00, 0xc0, 0x80, 0x7f, 0x07, 0xef, 0x01, 0x00, 0xcc, 0x01, 0x06, 0x0e,
   0xe7, 0x01, 0x00, 0xfc, 0x01, 0x06, 0x1e, 0xc7, 0x00, 0x00, 0xf8, 0x01,
   0x07, 0x1c, 0xc6, 0x00, 0x00, 0xf0, 0x83, 0x07, 0x3c, 0x86, 0x00, 0x00,
   0x80, 0x87, 0x07, 0x7c, 0x04, 0x00, 0x00, 0x00, 0x07, 0x07, 0x00, 0x00,
   0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
   0x00, 0x00, 0x00, 0x00, 0xe0, 0x03, 0x00, 0xc0, 0x00, 0x00, 0x00, 0xf0,
   0x0f, 0x00, 0xc0, 0x00, 0x00, 0x00, 0x18, 0x0c, 0x00, 0xc0, 0x00, 0x00,
   0x00, 0x08, 0x08, 0x00, 0xc0, 0x00, 0x00, 0x00, 0x0c, 0x40, 0x3b, 0xfc,
   0x00, 0x00, 0x00, 0x0c, 0xc0, 0x2f, 0xfe, 0x00, 0x00, 0x00, 0x0c, 0xc0,
   0x66, 0xc2, 0x00, 0x00, 0x00, 0x0c, 0xc0, 0x66, 0xc3, 0x00, 0x00, 0x00,
   0x08, 0xc0, 0x66, 0xc3, 0x00, 0x00, 0x00, 0x18, 0xc8, 0x66, 0xc3, 0x00,
   0x20, 0x00, 0x10, 0xcc, 0x66, 0xe6, 0x00, 0x60, 0x00, 0xf0, 0xc7, 0x66,
   0xbc, 0x01, 0x60, 0x00, 0xe0, 0xc3, 0x66, 0x00, 0x00, 0x60, 0x00, 0x00,
   0x00, 0x00, 0x00, 0x00, 0x67, 0x00, 0x00, 0x00, 0xe0, 0xf3, 0x3d, 0x69,
   0x00, 0x00, 0x00, 0x30, 0x96, 0x64, 0x67, 0x00, 0x00, 0x00, 0x30, 0x96,
   0x44, 0xe3, 0x00, 0x00, 0x00, 0xe0, 0x93, 0x44, 0xce, 0x00, 0x00, 0x00,
   0x20, 0xf0, 0xcd, 0x8c, 0x01, 0x00, 0x00, 0x20, 0x70, 0x8b, 0x00, 0x00,
   0x00, 0x00, 0x70, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
   0x00, 0x00};

/* global data */
Widget          topWidget;
BrowserStruct   browser[5];
GraphicsStruct  graphics[5];
AppRes          appres;
HistoStruct     histogram;

/* application resource list */
static XtResource resources[] = {
 { "autorefresh", "AutoRefresh", XmRBoolean, sizeof(Boolean),
 XtOffset(AppResPtr, auto_refresh), XmRImmediate, (caddr_t) True},
 { "echokuip", "EchoKuip", XmRBoolean, sizeof(Boolean),
 XtOffset(AppResPtr, echo_kuip_cmd), XmRImmediate, (caddr_t) False},
 { "doublebuffer", "DoubleBuffer", XmRBoolean, sizeof(Boolean),
 XtOffset(AppResPtr, double_buffer), XmRImmediate, (caddr_t) True},
 { "samezone", "SameZone", XmRBoolean, sizeof(Boolean),
 XtOffset(AppResPtr, same_zone), XmRImmediate, (caddr_t) False},
 { "hbookfile", "HbookFile", XmRString, sizeof (String),
 XtOffset(AppResPtr, hbook_file), XmRString, "hbook"},
};


static String fallbacks_hp[] = {
 "Paw++*kxtermGeometry:                  650x450+0+0",
 "Paw++*kuipGraphics_shell.geometry:     600x600-0+0",
 "Paw++*kuipBrowser_shell.geometry:      +0+485",
 "Paw++*histoStyle_shell.geometry:       +670+635",
 "Paw++*iconForeground:                  grey40",
 "Paw++*iconBackground:                  white",
 "Paw++*selectColor:                     green",
 "Paw++*matrix.evenRowBackground:        white",
 "Paw++*matrix.oddRowBackground:         antiquewhite",
 "Paw++*matrix.foreground:               black",
 "Paw++*matrix.gridType:                 XmGRID_SHADOW_IN",
 "Paw++*dirlist*dir*iconForeground:      blue",
 "Paw++*dirlist*1d*iconForeground:       DarkGoldenrod3",
 "Paw++*dirlist*2d*iconForeground:       DeepPink3",
 "Paw++*dirlist*ntuple*iconForeground:   SteelBlue3",
 "Paw++*dirlist*pict*iconForeground:     green4",
 "Paw++*dirlist*chain*iconForeground:    blue",
 "Paw++*dirlist*entry*iconForeground:    OrangeRed",
 "Paw++*dirlist*Cmd*iconForeground:      cyan4",
 "Paw++*dirlist*Menu*iconForeground:     blue",
 "Paw++*dirlist*MacFile*iconForeground:  OliveDrab4",
 "Paw++*dirlist*hbook*iconForeground:    red",
 "Paw++*dirlist*piafhb*iconForeground:   red",
 "Paw++*dirlist*iconLabelForeground:     white",
 "Paw++*dirlist*iconLabelBackground:     black",
 "Paw++*dirlist*fontList:                *-courier-bold-r-normal-*-120-*",
 "Paw++*versionMailLabel.fontList:       *-prestige-medium-r-normal-*-120-*",
 "Paw++*bugMailToggle.fontList:          *-swiss*742-bold-r-normal-*-140-*",
 "Paw++*commentMailToggle.fontList:      *-swiss*742-bold-r-normal-*-140-*",
 "Paw++*bugMailToggle.selectColor:       red",
 "Paw++*matrix.fontList:                 *-prestige-medium-r-normal-*-120-*",
 "Paw++*XmText*fontList:                 *-prestige-medium-r-normal-*-120-*",
 "Paw++*XmTextField*fontList:            *-prestige-medium-r-normal-*-120-*",
 "Paw++*kxtermTextFont:                  *-prestige-medium-r-normal-*-120-*",
 "Paw++*helpFont:                        *-prestige-medium-r-normal-*-120-*",
 "Paw++*fontList:                        *-swiss*742-bold-r-normal-*-120-*",
 "Paw++*kxtermFont:                      *-swiss*742-bold-r-normal-*-120-*",
 "Paw++*keyboardFocusPolicy:             pointer",
 "Paw++*doubleClickInterval:             400",
 NULL
};

static String fallbacks_any[] = {
 "Paw++*kxtermGeometry:                  650x450+0+0",
 "Paw++*kuipGraphics_shell.geometry:     600x600-0+0",
 "Paw++*kuipBrowser_shell.geometry:      +0+485",
 "Paw++*histoStyle_shell.geometry:       +670+635",
 "Paw++*iconForeground:                  grey40",
 "Paw++*iconBackground:                  white",
 "Paw++*selectColor:                     green",
 "Paw++*matrix.evenRowBackground:        white",
 "Paw++*matrix.oddRowBackground:         antiquewhite",
 "Paw++*matrix.foreground:               black",
 "Paw++*matrix.gridType:                 XmGRID_SHADOW_IN",
 "Paw++*dirlist*dir*iconForeground:      blue",
 "Paw++*dirlist*1d*iconForeground:       DarkGoldenrod3",
 "Paw++*dirlist*2d*iconForeground:       DeepPink3",
 "Paw++*dirlist*ntuple*iconForeground:   SteelBlue3",
 "Paw++*dirlist*pict*iconForeground:     green4",
 "Paw++*dirlist*chain*iconForeground:    blue",
 "Paw++*dirlist*entry*iconForeground:    OrangeRed",
 "Paw++*dirlist*Cmd*iconForeground:      cyan4",
 "Paw++*dirlist*Menu*iconForeground:     blue",
 "Paw++*dirlist*MacFile*iconForeground:  OliveDrab4",
 "Paw++*dirlist*hbook*iconForeground:    red",
 "Paw++*dirlist*piafhb*iconForeground:   red",
 "Paw++*dirlist*fontList:                *-courier-bold-r-normal--12-120-*",
 "Paw++*versionMailLabel.fontList:       *-courier-medium-r-normal--12-120-*",
 "Paw++*bugMailToggle.fontList:          *-helvetica-bold-r-normal--14-140-*",
 "Paw++*commentMailToggle.fontList:      *-helvetica-bold-r-normal--14-140-*",
 "Paw++*bugMailToggle.selectColor:       red",
 "Paw++*matrix.fontList:                 *-courier-medium-r-normal--12-120-*",
 "Paw++*XmText*fontList:                 *-courier-medium-r-normal--12-120-*",
 "Paw++*XmTextField*fontList:            *-courier-medium-r-normal--12-120-*",
 "Paw++*kxtermTextFont:                  *-courier-medium-r-normal--12-120-*",
 "Paw++*helpFont:                        *-courier-medium-r-normal--12-120-*",
 "Paw++*fontList:                        *-helvetica-bold-r-normal--12-120-*",
 "Paw++*kxtermFont:                      *-helvetica-bold-r-normal--12-120-*",
 "Paw++*keyboardFocusPolicy:             pointer",
 "Paw++*doubleClickInterval:             400",
 NULL
};


extern void show_aboutDialog(Widget);
extern void  (*user_logo_C)(Widget);

extern void show_mailDialog(Widget);
extern void  (*user_mail_C)(Widget);


/***********************************************************************
 *                                                                     *
 *   Called by KUIP before initializing an application.                *
 *                                                                     *
 ***********************************************************************/
String *get_paw_fallbacks ()
{
   String      *fallbacks;
   XFontStruct *font;
   Display     *dpy = XOpenDisplay(NULL);

   if (!dpy) {
      fprintf(stderr,
      "Error: Can't Open display. DISPLAY variable incorrectly set.\n");
      exit(1);
   }

   if ((font = XLoadQueryFont(dpy, "*-swiss*742-bold-r-normal-*-120-*")))
      fallbacks = fallbacks_hp;
   else
      fallbacks = fallbacks_any;

   XCloseDisplay(dpy);

   user_logo_C = show_aboutDialog; /* this should be set via the CDF */
   user_mail_C = show_mailDialog;  /* and this too... */

   return fallbacks;
}

/***********************************************************************
 *                                                                     *
 *   Clear browser widget.                                             *
 *                                                                     *
 ***********************************************************************/
static void destroy_browser(Widget w, int *which, XmAnyCallbackStruct *cbs)
{
   MenuCbStruct    *menu_item;
   long             i = (long) which;

   browser[i].widget = NULL;
   if (browser[i].open_dialog) {
      XtVaGetValues(browser[i].open_dialog, XmNuserData, &menu_item, NULL);
      XtFree((char *)menu_item);
      browser[i].open_dialog = NULL;
   }
   if (browser[i].close_dialog) {
      XtVaGetValues(browser[i].close_dialog, XmNuserData, &menu_item, NULL);
      XtFree((char *)menu_item);
      browser[i].close_dialog = NULL;
   }
}

/***********************************************************************
 *                                                                     *
 *   Clear graphics widget.                                            *
 *                                                                     *
 ***********************************************************************/
static void destroy_graphics(Widget w, int *which, XmAnyCallbackStruct *cbs)
{
   long   i = (long) which;

   graphics[i].widget = NULL;
}

/***********************************************************************
 *                                                                     *
 *   Called by KUIP after creating and initializing a KUIP window.     *
 *                                                                     *
 ***********************************************************************/
void init_top_level_window(char *name, Widget top)
{
   Pixmap    pixmap;
   Display  *display;

   if (strcmp(name,"kuipPanel") == 0) {
      /* set Command Panel icon */
      display = XtDisplay(top);
      pixmap = XCreateBitmapFromData(display, DefaultRootWindow(display),
                                     command_bits, command_width,
                                     command_height);
      XtVaSetValues(XtParent(top), XmNiconPixmap, pixmap,
                                   NULL);
   }

   if (strncmp(name, "kuipBrowser", 11) == 0) {
      if (strcmp(name, "kuipBrowser1") == 0) {
         topWidget = top;
         XtGetApplicationResources(XtParent(XtParent(topWidget)), &appres,
                                   resources, XtNumber(resources), NULL, 0);
         browser[0].widget = top;
         XtAddCallback(top, XmNdestroyCallback,
                       (XtCallbackProc)destroy_browser, (int *) 0);
      }
      if (strcmp(name, "kuipBrowser2") == 0) {
         browser[1].widget = top;
         XtAddCallback(top, XmNdestroyCallback,
                       (XtCallbackProc)destroy_browser, (int *) 1);
      }
      if (strcmp(name, "kuipBrowser3") == 0) {
         browser[2].widget = top;
         XtAddCallback(top, XmNdestroyCallback,
                       (XtCallbackProc)destroy_browser, (int *) 2);
      }
      if (strcmp(name, "kuipBrowser4") == 0) {
         browser[3].widget = top;
         XtAddCallback(top, XmNdestroyCallback,
                       (XtCallbackProc)destroy_browser, (int *) 3);
      }
      if (strcmp(name, "kuipBrowser5") == 0) {
         browser[4].widget = top;
         XtAddCallback(top, XmNdestroyCallback,
                       (XtCallbackProc)destroy_browser, (int *) 4);
      }

      /* set browser icon */
      display = XtDisplay(top);
      pixmap = XCreateBitmapFromData(display, DefaultRootWindow(display),
                                     browser_bits, browser_width,
                                     browser_height);
      XtVaSetValues(XtParent(top), XmNiconPixmap, pixmap,
                                   NULL);
   }

   if (strncmp(name, "kuipGraphics", 12) == 0) {
      if (strcmp(name, "kuipGraphics1") == 0) {
         graphics[0].widget = top;
         XtAddCallback(top, XmNdestroyCallback,
                       (XtCallbackProc)destroy_graphics, (int *) 0);
      }
      if (strcmp(name, "kuipGraphics2") == 0) {
         graphics[1].widget = top;
         XtAddCallback(top, XmNdestroyCallback,
                       (XtCallbackProc)destroy_graphics, (int *) 1);
      }
      if (strcmp(name, "kuipGraphics3") == 0) {
         graphics[2].widget = top;
         XtAddCallback(top, XmNdestroyCallback,
                       (XtCallbackProc)destroy_graphics, (int *) 2);
      }
      if (strcmp(name, "kuipGraphics4") == 0) {
         graphics[3].widget = top;
         XtAddCallback(top, XmNdestroyCallback,
                       (XtCallbackProc)destroy_graphics, (int *) 3);
      }
      if (strcmp(name, "kuipGraphics5") == 0) {
         graphics[4].widget = top;
         XtAddCallback(top, XmNdestroyCallback,
                       (XtCallbackProc)destroy_graphics, (int *) 4);
      }

      /* set graphics icon */
      display = XtDisplay(top);
      pixmap = XCreateBitmapFromData(display, DefaultRootWindow(display),
                                     graphics_bits, graphics_width,
                                     graphics_height);
      XtVaSetValues(XtParent(top), XmNiconPixmap, pixmap,
                                   NULL);
   }
}

