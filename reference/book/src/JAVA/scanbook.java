import java.io.*;
import java.util.Vector;
import java.awt.*;               // ScrollPane, PopupMenu, MenuShortcut, etc..
//import java.awt.event.*;         // New event model.
import java.awt.event.TextListener;
import java.awt.event.TextEvent;
import java.awt.event.ItemListener;
import java.awt.event.ItemEvent;
import java.awt.event.ActionListener;
import java.awt.event.ActionEvent;
import java.applet.Applet;
import netscape.security.PrivilegeManager;
import java.security.*;
import java.lang.Math;
import java.net.*;
import java.applet.*;

public class scanbook extends Applet{

  static Applet a;
  static menu1 m1;
  static page2  m2 = null;
  //static Color fg = new Color(0,230,230);
  static Color fg = new Color(0,180,255);
  //  static Color bg = new Color(0,255,120);
  static Color bg = new Color(218,218,193);
  static Cursor watchCursor = new Cursor(Cursor.WAIT_CURSOR);
  static Cursor defaultCursor;
    //  static Font myFont;
  static scanbookFont myFont;
  static outCards cards = null;
  static Vector allOutCards = new Vector(0);
  static boolean newSelection = true;
    //  static int debugLevel = 1;
  static debugger dbg = new debugger();
  static boolean netscaperun = true;
  static boolean inBrowser = true;
  static boolean running = false;
  static scanbookProperties scbProp;
  static String  osArch = "";
  static String  osName = "";
  static String  userName = "";
  static String homedir;
  static String Navigator= "";
  static String ipAddress= "";
  static String defaultEdir = "Default";
  static int  initialDebug = 0;
  static statsWindow stats = null;
  static String defaultSaveDir = "./";

  public static void main(String argv[]) {
/*
|| This is the entry point when running as an application
||
*/
      Navigator = "JDK";
      netscaperun = false;
      inBrowser = false;
      running = true;
      amain(argv);
  }
  public void mystart(String browser){
/*
|| This is the true entry point when running inside a browser;
|| browser is the name of the browser, passed from the javascript
|| 
*/
      a = this;
      Navigator = browser;
      if(running){
	  if(m1 != null)m1.setVisible(true);
      }else{
        System.out.println("Running under *"+browser+"*");
        if(browser.equals("Netscape")){
	    netscaperun = true;
	}else{
	    netscaperun = false;
	}
        if(checkSecurity()){
          running = true;
          amain(new String[]{});
	}else{
           errorMessage msg = new errorMessage(
                             (Frame)scanbook.a.getParent(),"");   
           msg.newline("Security privileges are not sufficient,");
           msg.newline("Scanbook will not run");
           msg.display();
           System.out.println("Security not granted");    
	}
      }
  }    

  public static void openWeb(Frame f, String theURL){
	URL url;
	AppletContext ac=null;

        f.setCursor(scanbook.watchCursor);

        if(scanbook.netscaperun){
            try{
              url = new URL(theURL);	  
              if(ac == null){
	        ac = scanbook.a.getAppletContext();
	      }
              ac.showDocument(url,"Scanbook WWW sel");
	    }catch(MalformedURLException me){
             System.err.println("Incorrect URL : "+theURL);
            }
	}else{
          systemcmd.execute("netscape -remote "+
	    "'openURL("+theURL+",new-window)'", true);
          f.setCursor(scanbook.defaultCursor);
          if(systemcmd.inOutput("netscape: not running on display")){
              errorMessage msg = new errorMessage(f,"");
              msg.newline("If you want to see the web page,");
              msg.newline("you should be running Netscape.");
              msg.newline(" ");
              msg.newline("Please launch Netscape on some shell"+
                        " window on this machine");
              msg.newline("and try again");
              msg.display();
          }
	}
  }

  public void setDebugOn(){
     System.out.println("Turning debug on");
     initialDebug = 1;
     scanbook.dbg.setlevel(1);  
  }
  public void setDebugOff(){
     System.out.println("Turning debug off");
     scanbook.dbg.setlevel(0);  
  }
  public void mystop(){
      if(running){
  	    if(m1 != null){
               m1.storeLocation();
               m1.setVisible(false);
	    }
	    if(m2 != null)m2.setVisible(false);
      }
  }    
  public static void stopProgram(){
      stopProgram(true);
  }
  public static void stopProgram(boolean confirm){
/*
|| The procedure to stop the program is different if we are an applet
|| or a procedure. For the applet, we simply make the windows invisible;
|| for the application, we also exit.
|| In both cases we need to close the fili cards output windows which may
|| have been opened.
|| 
*/
            int nelem = allOutCards.size();
            for(int i=0; i<nelem; i++){
		((Frame)allOutCards.elementAt(i)).dispose();
            }
            allOutCards.removeAllElements();
            if(scbProp != null)scbProp.cancelDisplay();
      if(running){
	  if(inBrowser){
  	    if(m1 != null){
               m1.storeLocation();
               m1.setVisible(false);
	    }
	    if(m2 != null)m2.setVisible(false);
	  }else{
	      if(confirm){
                 if(confirmQuit()){
                   System.exit(0);
		 }
	      }else{
                 System.exit(0);
	      }
	  }
      }
  }    
  static boolean confirmQuit(){
      if(m1 != null && m1.isVisible())oconnect.setCurrentFrame(m1);
      if(m2 != null && m2.isVisible())oconnect.setCurrentFrame(m2);
      yesNo confirm = new yesNo(oconnect.currentFrame,
                           "Do you really want to quit ?");
      confirm.display();
      return confirm.yes;
  }
  public static void amain(String argv[]) {
/*
|| This is the real entry point to the program. It is called in both cases :
|| applet or application.
|| 
*/
    if(argv.length > 0){
      System.out.println("Using package : "+argv[0]);
      String udev = oconnect.orawebDev;
      System.out.println("at URL  : "+udev);
      oconnect.setPackage(argv[0]); 
      oconnect.setoraweb(udev);
    }     
    scbProp = new scanbookProperties(scanbook.netscaperun);
    if(scanbook.netscaperun){
      try{
          PrivilegeManager.enablePrivilege("UniversalPropertyRead");
      }
      catch (Exception exc) {
         System.err.println(exc); 
      }
      myFont = new scanbookFont(scbProp.getProperty("NetscapeFontSize"));
    }else{
      myFont = new scanbookFont(scbProp.getProperty("fontSize"));
    }
    defaultEdir = scbProp.getProperty("defaultEdir");
    osArch = System.getProperty("os.arch");
    osName = System.getProperty("os.name");
      userName = System.getProperty("user.name");
      homedir = System.getProperty("user.home");
// Set debug level to  initialDebug (0 =  go to file)
      scanbook.dbg.setlevel(initialDebug);
      ipAddress = getIpAddress();
    m1 = new menu1(fg, bg);
//
//Set proxy (if needed)
//
    if(ipAddress.startsWith("127.0.0")){
      System.getProperties().put("proxySet", "true");
      System.getProperties().put("proxyHost", "localhost");
      System.getProperties().put("proxyPort", "8080");
    }
    begin();
  }
  static void begin(){
/*
|| Here we do whatever needs to be redone each time we restart the program :
|| All objects are recreated and refreshed with new info from the Oracle DB.
|| One peculiar case is when we press the Apply button from the properties
|| dialog : restarting from scratch guarantees that all properties will be
|| taken into account.
|| 
*/
    newSelection = true;
    if(m2 != null){
        m2.setVisible(false);
        m2.dispose();
    }
    m1.kingalCond.removeAll();
    oconnect.setCurrentFrame(m1);
    m2 = null;
    oconnect c; 
    c = new oconnect("init");
    if(c.put_value(null,null,true)){
      c.fillList(new fillable[] {
           m1.rof, 
           m1.selectYear,
           m1.mcchoice.selectYear,
           m1.mcchoice.kinlist,
           m1.inst,
           m1.datasetType,
           m1.whatyouwant
           });
      callbacks("typedat","Real DATA");
      callbacks("selby","YEAR");
      c = null;
    }else{
        stopProgram(false);
    }
      m1.setAspect();
      m1.packshow();
      oconnect.setCurrentFrame(m1);
  }
  static String getIpAddress(){
    String addr = "";
    try {
      InetAddress myhost = InetAddress.getLocalHost();
      scanbook.dbg.out(" Node ** name = "+myhost.getHostName()+" "+
                           myhost.getHostAddress());
      //addr = myhost.getHostAddress();
      addr = myhost.getHostName();
    }catch (Exception exc) {
         System.err.println("UniversalPropertyRead not given"); 
    }
    return addr;
  }

  static boolean checkSecurity(){
/*
|| Verify that all privileges which will be needed later are granted,
|| so that we can stop immediately the program in case of a problem.
|| 
*/
    boolean result = true;
    if(scanbook.netscaperun){
      try{
          PrivilegeManager.enablePrivilege("UniversalPropertyRead");
      }
      catch (Exception exc) {
         System.err.println("UniversalPropertyRead not given"); 
         result = false;
      }
      try{
          PrivilegeManager.enablePrivilege("UniversalConnect");
      }
      catch (Exception exc) {
         System.err.println("UniversalConnect not given"); 
         result = false;
      }
      try{
          PrivilegeManager.enablePrivilege("UniversalFileRead");
      }
      catch (Exception exc) {
         System.err.println("UniversalFileRead not given"); 
         result = false;
      }
      try{
          PrivilegeManager.enablePrivilege("UniversalFileWrite");
      }
      catch (Exception exc) {
         System.err.println("UniversalFileWrite not given"); 
         result = false;
      }
/* We do not need that anymore ....
      try{
          PrivilegeManager.enablePrivilege("UniversalExecAccess");
      }
      catch (Exception exc) {
         System.err.println("UniversalExecAccess not given"); 
         result = false;
      }
*/
    }
    return result;
  }
  static void mySetCursors(Cursor cursor){
      //     System.out.println("******* Set cursor  **********>>>>>");
    int nelem = allOutCards.size();
    for(int i=0; i<nelem; i++){
       ((Frame)allOutCards.elementAt(i)).setCursor(cursor);;
    }
    if(m1 != null){
      m1.setCursor(cursor);
    }
    if(m2 != null){
      m2.setCursor(cursor);
    }
    /*
    if(cards != null){
      cards.setCursor(cursor);
    }
    */
  }
  static void showStats(){
/*
|| This controls the "camambert" window
|| 
*/
    if(stats == null){
      stats = new statsWindow();
    }else{
      stats.show();
    }
  }
  public static void callbacks(String menu, String option){
          option = option.trim();
	  scanbook.dbg.out("Option *"+option+"* from menu "+menu);
  //          System.out.println("Option *"+option+"* from menu "+menu);
    if(option.equals("STOP")){
	//      System.exit(0);
        stopProgram();
    }
    mySetCursors(watchCursor);
    if(menu.equals("configFrame") && option.equals("rebuild")){
      m1.storeLocation();
      m1.setVisible(false);
      m1.rebuildmain(fg,bg);
      begin();
      m1.setVisible(true);
    }
    if(menu.equals("stopcont") && option.equals("CONTINUE")){
      String action = m1.whatyouwant.getSelectedAction();
      //      System.out.println("Selected action : *"+action+"*");
      if(action != null && action.equals("RunorCart")){
        if(m1.runCartPanel.verifyText()){
           cards = new outCards();
           allOutCards.addElement(cards);
           String callProc;
	   callProc = "write_RunorCart";
           oconnect cloc = new oconnect(callProc);
           cards.setCallingProcedure(callProc);
           m1.sendSelections(cloc);
           if(cloc.put_value(null,null,true)){
             cards.fillall(cloc);
             cards.show();
             oconnect.setCurrentFrame(cards);
	   }
	}
      }else if(action != null && action.equals("Impatient")){
           cards = new outCards();
           allOutCards.addElement(cards);
           oconnect cloc = new oconnect("ImpatientStream");
           if(cloc.put_value("action","sendCards",false)&&
	     cloc.put_value("file",m1.imp.getSelection(),true)){
             cards.fillall(cloc);
             cards.manipulateClist(cards.selections,true);
             cards.show();
             oconnect.setCurrentFrame(cards);
	   }
      }else if(action != null && action.equals("Globalstat")){
           cards = new outCards();
           allOutCards.addElement(cards);
           oconnect cloc = new oconnect("write_GlobalStat");
           m1.sendSelections(cloc);
           if(cloc.put_value(null,null,true)){
	       //             cards.selVisible = false;
             cards.fillall(cloc);
             cards.manipulateClist(cards.selections,true);
             cards.show();
             oconnect.setCurrentFrame(cards);
	   }
      }else{
        if(m1.rof.verifyText()){
          if(newSelection){
            oconnect c = new oconnect("init2");
            m1.sendSelections(c);
            if(c.put_value(null,null,true)){
              if(m2 == null){
                m2 = new page2(c, fg, bg);
              }
              m2.fillAll(c);
              m2.phyGrps.setVisible(false);
              m1.storeLocation();
              m1.setVisible(false); 
              m2.setVisible(true);
              m2.relocate();
              oconnect.setCurrentFrame(m2);
              m2.pack();
	    }
	  }else{
	      m2.setVisible(true);
              m2.relocate();
              m1.storeLocation();
	      m1.setVisible(false);
	  }
	}
      }
    }
    if(menu.equals("stopcont") && option.equals("RELOAD")){
      m1.fillTypeData();
      begin();
    }
    if(menu.equals("selby")){
      if(option.equals("YEAR")){
	m1.switchcards1(menu1.BYYEAR);
      }else{
        m1.switchcards1(menu1.ROF);
      }
    }
    if(menu.equals("wantwhat")){
        m1.switchcards3(menu1.NORMALPANEL);
    }
    if(menu.equals("wantwhat_action")){
      if(option.equals("RunorCart")){
        m1.switchcards3(menu1.RUNCARTPANEL);
      }else if(option.equals("Impatient")){
        m1.switchcards3(menu1.IMPATIENT);
        oconnect cloc = new oconnect("ImpatientStream");
        if(cloc.put_value("action","sendButtons",true)){
          cloc.fillList(new fillable[]{m1.imp});
        }else{
//           reload if it has failed ...
             m1.fillTypeData();
             begin();
	}
      }else{
        m1.switchcards3(menu1.NORMALPANEL);
      }
    }
    if(menu.equals("typedat")){
      if(option.equals("Real DATA")){
	m1.switchcards2(menu1.DATACHOICE);
        m1.kingalCond.setVisible(false);
        m1.packshow();
      }else{
        m1.switchcards2(menu1.MCCHOICE);
	//        m1.kingalCond.showIfNeeded();
	//        m1.kinMasses.setVisible(m1.kingalCond.isVisible());
      }
        m1.setAspect();
        oconnect cloc = new oconnect("fill_other_menus");
	cloc.put_value("menutype","TypeofData");
	cloc.put_value("typedat",option);
	cloc.put_value("page_number","1",true);
        cloc.fillList(m1.datasetType);
    }
    if(menu.equals("institute")){
        oconnect ckby = new oconnect("kinbyyear");
	ckby.put_value("institute",option);
	ckby.put_value("mcyear",m1.mcchoice.selectYear.getSelection(),true);
        ckby.fillList(m1.mcchoice.kinlist);
        m1.kingalCond.resetEmpty();
    }
    if(menu.equals("McYear")){
        oconnect ckby = new oconnect("kinbyyear");
	ckby.put_value("mcyear",option);
	ckby.put_value("institute",m1.inst.getSelection(),true);
        ckby.fillList(m1.mcchoice.kinlist);
        m1.kingalCond.resetEmpty();
        m1.setAspect();
    }
    if(menu.equals("Kinlist")){
        oconnect cloc = new oconnect("kincomments");
	//        m1.mcchoice.selectYear.sendSelection(cloc);
        cloc.sendSelection(m1.mcchoice.selectYear);
	cloc.put_value("kinlist",option);
	cloc.put_value("institute",m1.inst.getSelection(),true);
        cloc.fillList(new fillable[]{
                                     m1.kingalCond,
                                     m1.kinMasses
                                    });
        m1.setAspect();
        m1.pack();
    }
    if(menu.equals("kinMass")){
        oconnect cloc = new oconnect("kincomments");
        cloc.sendSelection(m1.mcchoice.selectYear);
	cloc.put_value("kinlist",m1.mcchoice.kinlist.getSelection());
	cloc.put_value("institute",m1.inst.getSelection());
	cloc.put_value("KinMass",option,true);
        cloc.fillList(new fillable[]{
                                     m1.kingalCond,
                                    });
        m1.setAspect();
	//        m1.pack();
    }
// Menus second page 
    if(menu.equals("BackStopCont") && option.equals("BACK")){
      m2.setVisible(false); 
      m1.setVisible(true); 
      m1.relocate();
      oconnect.setCurrentFrame(m1);
    }
    if(menu.equals("BackStopCont") && option.equals("GO")){
         scanbook.dbg.out("GO");
         String s = m2.phyGrps.getSelection();
         scanbook.dbg.out("Radio selections : " + s);
         cards = new outCards();
         allOutCards.addElement(cards);
         oconnect cloc;
         String callProc;
         if(m2.wt.wtype.equals("RunsInfo")){
	    callProc = "write_srun_RunsInfo";
	 }else{
	    callProc = "write_fili_srun_cards";
	 }
         cloc = new oconnect(callProc);
         cards.setCallingProcedure(callProc);
         m1.sendSelections(cloc);
         m2.sendSelections(cloc);
         cloc.put_value("aledir",defaultEdir,false);
         cloc.put_value(null,null,true);
         cards.fillall(cloc);
         cards.show();
         oconnect.setCurrentFrame(cards);
    }
    if(menu.equals("Runquality")){
       if(option.equals("Phys. Groups")){
         m2.phyGrps.setVisible(true);
       }else{
         m2.phyGrps.setVisible(false);
         oconnect cloc = new oconnect("give_processing_level");
         m1.sendSelections(cloc);
         cloc.sendSelection(m2.runQuality);
         cloc.sendSelection(m2.phyGrps);
         cloc.sendSelection(m2.lepEnergies);
         cloc.put_value(null,null,true);
         cloc.fillList(m2.processings);
       }
       m2.setAspect();
    }
    if(menu.equals("PhysGroups")){
	 scanbook.dbg.out("phyGrps"+option);
         oconnect cloc = new oconnect("give_processing_level");
         m1.sendSelections(cloc);
         cloc.sendSelection(m2.runQuality);
         cloc.sendSelection(m2.phyGrps);
         cloc.sendSelection(m2.lepEnergies);
         cloc.put_value(null,null,true);
         cloc.fillList(m2.processings);
    }
    if(menu.equals("energy_Lep")){
       oconnect cloc = new oconnect("changed_lepenergy");
       m1.sendSelections(cloc);
       cloc.put_value(menu,option,false);
       cloc.sendSelection(m2.runQuality);
       cloc.sendSelection(m2.phyGrps);
       cloc.put_value(null,null,true);
       cloc.fillList(new fillable[] {
	   m2.specialParticles,m2.mcDatasets,m2.processings
                                    });
    }
    if(menu.equals("specpar")){
       oconnect cloc = new oconnect("give_mcdatasets");
       m1.sendSelections(cloc);
       cloc.put_value(menu,option,false);
       cloc.sendSelection(m2.lepEnergies);
       cloc.put_value(null,null,true);
       cloc.fillList(m2.mcDatasets);
    }
    if(menu.equals("useWsel")){
       if(option.equals("View")){
         viewWsel vWs = new viewWsel();
         oconnect cloc = new oconnect("give_WWBadRuns");
         cloc.put_value(null,null,true);
         cloc.fillList(vWs.runsList);
         vWs.relocate();
       }
       if(option.equals("Open web page")){
	   //	 vWs.setVisible(false);
         openWeb(m2,"http://alephwww.cern.ch/~sical/Wlumi");
       }
    }
    if(menu.equals("BackStopCont") && option.equals("BACK")){
       newSelection = false;
    }else{
       if(!(menu.equals("stopcont") && option.equals("CONTINUE"))){
           newSelection = true;
       }
    }
    if(m1 != null){
      if(m1.verifyInput())m1.buttons.setEnabled("CONTINUE",true);
      else m1.buttons.setEnabled("CONTINUE",false);
      String ac = m1.whatyouwant.getSelectedAction();
      if(menu.equals("wantwhat")){
        if(ac != null && ac.equals("Calib")){
	    m1.datasetType.disableSome(new String[]{"MINI","DST"});
        }else if(ac != null && ac.equals("Impatient")){
	    m1.datasetType.disableSome(new String[]{"RAW","MINI","DST"});
        }else{
	    m1.datasetType.disableSome(new String[]{});
        }
	m1.datasetType.setVisible(true);
        if(ac != null && ac.equals("RunsInfo")){
	    m1.datasetType.setVisible(false);
        }
      }
      m1.pack();
    }
    if(m2 != null){
      if(m2.processings.isVisible() && !m2.verifyInput()){
          m2.buttons.setEnabled("GO",false);
      }else{
        m2.buttons.setEnabled("GO",true);
      }
      if(m2.lepEnergies.getSelection().trim().equals("ANY") ||
         m2.lepEnergies.getSelection().trim().equals("ALL LEP1.5") ||
         m2.lepEnergies.getSelection().trim().equals("ALL LEP2") ||
         (m2.lepEnergies.getSelection().trim().indexOf("->") != -1)
	 ){
         m2.filisorted.setEnabled(true);
      }else{
         m2.filisorted.setEnabled(false);
      }
      m2.pack();
    }
        mySetCursors(defaultCursor);
  }
}

class outCards extends Frame implements ActionListener{
  MenuBar mb = new MenuBar();
  Menu fileMenu = new Menu("File");
  //  Menu srunMenu = new Menu("SRUN");
  Menu helpMenu = new Menu("Help");
  cardsList date = new cardsList(TextArea.SCROLLBARS_VERTICAL_ONLY);
  cardsList srunCards = new cardsList(TextArea.SCROLLBARS_VERTICAL_ONLY);
  cardsList filiCards = new cardsList(TextArea.SCROLLBARS_VERTICAL_ONLY);
  cardsList selections = new cardsList(TextArea.SCROLLBARS_VERTICAL_ONLY);
  cardsList HTMLselections = new cardsList(TextArea.SCROLLBARS_VERTICAL_ONLY);
  cardsList output = new cardsList(TextArea.SCROLLBARS_VERTICAL_ONLY);
  GridBagLayout gbl = new GridBagLayout();
  GridBagConstraints gbc = new GridBagConstraints();
    /*
  boolean dateVisible = true;
  boolean filiVisible = true;
  boolean srunVisible = true;
  boolean selVisible = true;
  boolean outputVisible = true;
    */
    //  String defaultFile = "scanbook.filicards";
  String defaultFile = "jscanbook";
  buttonsMenu buttons;
  ScrollPane mainContainer = new ScrollPane(); 
  Panel mainPanel = new Panel(); 
  int cardsWidth;
  String callingProcedure = "write_fili_srun_cards";

  outCards(){
    super("Fili Cards");
    //    setSize(1000,700);
    setVisible(false);
    gbc.gridx = 0;
    gbc.gridy = GridBagConstraints.RELATIVE;
    gbc.gridwidth = GridBagConstraints.REMAINDER;
    gbc.weightx = 0.;
    gbc.weighty = 0.;

    setMenuBar(mb);    
    mb.add(fileMenu);
    //    mb.add(srunMenu);
    mb.setHelpMenu(helpMenu);
    fileMenu.addActionListener(this);
    //    srunMenu.addActionListener(this);
    fileMenu.add("Save");
    fileMenu.add("Save as");
    fileMenu.add("Save HTML");
    //    fileMenu.add("Print");
    fileMenu.add("Close");
    fileMenu.add("Quit");

    add(mainContainer);
    mainContainer.add(mainPanel);
    mainPanel.setLayout(gbl);

    buttons = new buttonsMenu("outcardsbuttons",
                           scanbook.fg,scanbook.bg);
    buttons.setListener(this);

    addClist(buttons);
    addClist(date);
    //    addClist(selections);
    addClist(selections);
    addClist(filiCards);
    addClist(srunCards);
    addClist(output);
    HTMLselections.removeAll();
    HTMLselections.setFont(scanbook.myFont);
    selections.removeAll();
    scanbook.m1.sendSelections(selections, "* ","=>","",false,false);
    scanbook.m1.sendSelections(HTMLselections, "\"&","=","\"+",true,false);
    if(scanbook.m2 != null){
    scanbook.m2.sendSelections(selections, "* ","=>","",false,true);
    scanbook.m2.sendSelections(HTMLselections, "\"&","=","\"+",true,true);
    }
    HTMLselections.myResize();

    scanbook.dbg.out("******* Selections : \n"+HTMLselections.getText());
    scanbook.dbg.out("******* Sel : \n"+selections.getText());
    buttons.addItem("DATE");
    buttons.addItem("SELECTIONS");

    setLocation(10,50);
  }
  void fillall(oconnect c){
    c.fillList(new fillable[] {
      filiCards,srunCards,date,output
           });
    pack();

    int newLinewidth = Math.max(date.maxLineWidth,
                        Math.max(selections.maxLineWidth,
                           Math.max(filiCards.maxLineWidth,
		               Math.max(srunCards.maxLineWidth,
                                         output.maxLineWidth))));
    int newWidth = Math.max(buttons.getPreferredSize().width,
                      Math.max(date.bestWidth,
                        Math.max(selections.bestWidth,
                           Math.max(filiCards.bestWidth,
		               Math.max(srunCards.bestWidth,
                                         output.bestWidth)))))+150;


    cardsWidth = newWidth;
    date.myResize(newWidth,newLinewidth);
    selections.myResize(newWidth,newLinewidth);
    if(filiCards.ncards == 0){
	filiCards.setVisible(manipulateClist(filiCards,true));
//      filiVisible = false;
//      manipulateClist(filiCards,true);
    }else{
      filiCards.myResize(newWidth,newLinewidth);
      //      cHeight += filiCards.getSize().height;
      buttons.addItem("FILI");
    }
    if(srunCards.ncards == 0){
      srunCards.setVisible(manipulateClist(srunCards,true));
      	//      srunVisible = false;
	//manipulateClist(srunCards,true);
    }else{
      srunCards.myResize(newWidth,newLinewidth);
      //      cHeight += srunCards.getSize().height;
      buttons.addItem("SRUN");
    }
    if(output.ncards == 0){
	output.setVisible(manipulateClist(output,true));
	//      outputVisible = false;
	//      manipulateClist(output,true);
    }else{
      output.myResize(newWidth,newLinewidth);
      //      cHeight += output.getSize().height;
      buttons.addItem("OUTPUT");
    }
    mypack();
  }
  void mypack(){
      int cHeight = buttons.getSize().height +
                     date.getSize().height; 

      int windowWidth = Math.max(cardsWidth,buttons.getPreferredSize().width);
      if(selections.isVisible()){
        cHeight += selections.getSize().height;
      }
      if(filiCards.isVisible()){
        cHeight += filiCards.getSize().height;
      }
      if(srunCards.isVisible()){
        cHeight += srunCards.getSize().height;
      }
      if(output.isVisible()){
        cHeight += output.getSize().height;
      }
      cHeight += 10;
      Toolkit t = Toolkit.getDefaultToolkit();
      Dimension d = t.getScreenSize();
      int sizel = d.height - 200;
      if(cHeight > sizel)cHeight = sizel;
      int cWidth = windowWidth;
      if(cWidth > d.width-100) cWidth = d.width - 100;
      mainContainer.setSize(cWidth,cHeight+10);
      pack();
  }
  void addClist(Component c){
    gbl.setConstraints(c,gbc);
    c.setFont(scanbook.myFont);
    mainPanel.add(c);
  }
  void addClist(Component c, int pos){
    GridBagConstraints gbcl = (GridBagConstraints)gbc.clone();
    gbl.setConstraints(c,gbcl);
    c.setFont(scanbook.myFont);
    mainPanel.add(c);
  }
  void saveFile(String fileName){
    File localfile = new File(fileName);
    System.out.println(" Saving into : "+fileName); 
    scanbook.mySetCursors(scanbook.watchCursor);
    if(scanbook.netscaperun){
      try{
          PrivilegeManager.enablePrivilege("UniversalFileRead");
          PrivilegeManager.enablePrivilege("UniversalFileWrite");
      }
      catch (Exception exc) {
         System.err.println(exc);
      }
    }
    String[] allE = filiCards.getAllEnergies();
    allE = filiCards.getAllEnergies(allE);
    allE = selections.getAllEnergies(allE);
    int n = allE.length;

    String[] filesExist = new String[n];
    int nexist = 0;

    boolean manyFiles = (fileName.indexOf("$") > -1);

    if(localfile.exists() && (n==1 || !manyFiles)){
	filesExist[0] = fileName;
        nexist = 1;
    }

    String loopfile = fileName;
    String workfile;
    String firstPart;
    String lastPart;
    int pos;
    String[] fileNames = new String[n];
    if(n>1 && manyFiles){
     for(int i=0; i<n; i++){
       loopfile = "";
       workfile = fileName;
       lastPart = workfile;
       while( (pos = workfile.indexOf("$")) > -1){
         firstPart = workfile.substring(0,pos);
         lastPart = workfile.substring(pos+1);
         loopfile = loopfile.concat(firstPart);
         loopfile = loopfile.concat(allE[i].replace('.','_'));
         workfile = lastPart;
       }
       loopfile = loopfile.concat(lastPart);
       if(!allE[i].equals("")){
         localfile = new File(loopfile);
         if(localfile.exists()) {
            filesExist[nexist++] = loopfile;
         }
       }
       fileNames[i] = loopfile;
     }
    }
    if(nexist>0){
      yesNo msg = new yesNo(
                             this,"File(s) exist :");   
      for(int i=0; i<nexist; i++){
        msg.newline(filesExist[i]);
      }
      msg.newline("Overwrite ?");
      msg.display();
      if(msg.no)return;
    }
    String blankE = "";
    if(!manyFiles) {
      n=1;
      fileNames[0] = fileName;
      allE[0] = null;
      blankE = null;
    }
    for(int i=0; i<n; i++){
      if(n>1){
         if(allE[i].equals(""))continue;     // do not create a new file 
                                             // for blank lep energy
         loopfile = fileNames[i];
      }
      try{
          PrintWriter pw = new PrintWriter(
                         new BufferedWriter(
                             new FileWriter(loopfile)));
	  date.writeToFile(pw,blankE);
          selections.writeToFile(pw,blankE);
          if(n>1) filiCards.writeToFile(pw,blankE);
          filiCards.writeToFile(pw,allE[i]);
          if(n>1) srunCards.writeToFile(pw,blankE);
          srunCards.writeToFile(pw,allE[i]);
          output.writeToFile(pw,allE[i]);
          pw.flush();
          pw.close();
      }catch (Exception exc) {
        System.err.println(exc);
        errorMessage msg = new errorMessage(
                             this,"Error writing filicards file :");   
        msg.newline(String.valueOf(exc));
        msg.newline("Abort");
        msg.display();
      }
      scanbook.mySetCursors(scanbook.defaultCursor);
    }
  }
  void saveHTML(String fileName){
    File localfile = new File(fileName);
    System.out.println(" *********** HTML Saving into : "+fileName); 
    scanbook.mySetCursors(scanbook.watchCursor);
    if(scanbook.netscaperun){
      try{
          PrivilegeManager.enablePrivilege("UniversalFileRead");
          PrivilegeManager.enablePrivilege("UniversalFileWrite");
      }
      catch (Exception exc) {
         System.err.println(exc);
      }
    }
    if(localfile.exists()){
      yesNo msg = new yesNo(
                             this,"File exists :");   
      msg.newline(fileName);
      msg.newline("Overwrite ?");
      msg.display();
      if(msg.no)return;
    }
      try{
        PrintWriter pw = new PrintWriter(
                         new BufferedWriter(
                             new FileWriter(fileName)));
        pw.println("<HTML> <SCRIPT LANGUAGE=\"JavaScript\">");
	pw.println("window.location = \""+oconnect.oraweb+"\"+");
        pw.println("\""+oconnect.pckg+".general"+"?ProgVers="+
                   scanbook_version.VERSION+"&\"+");
        pw.println("\"web_output=Yes&procname="+callingProcedure+"\"+");
//	System.out.println("******* Selections : \n"+HTMLselections.getText());
        String txt = HTMLselections.getText();
        int len = txt.length();
        String goodtext = txt.substring(0,len-1) + ";";
	pw.println(goodtext);
	pw.println("</SCRIPT> </HTML>");
        pw.flush();
        pw.close();
      }catch (Exception exc) {
        System.err.println(exc);
        errorMessage msg = new errorMessage(
                             this,"Error writing filicards file :");   
        msg.newline(String.valueOf(exc));
        msg.newline("Abort");
        msg.display();
      }
      scanbook.mySetCursors(scanbook.defaultCursor);
  }
  public void setCallingProcedure(String s){
    callingProcedure = s;
  }
  String defaultType(){
      //    if(filiVisible){
    if(filiCards.isVisible()){
        return ".filicards";
    }
    //    if(outputVisible){
    if(output.isVisible()){
        return ".output";
    }
    //    if(srunVisible){
    if(srunCards.isVisible()){
        return ".sruncards";
    }
    return ".output";
  }
  public void actionPerformed(ActionEvent e) {
    String action = e.getActionCommand(); 
    if(action.equals("Quit")){
	//      System.exit(0);
        scanbook.stopProgram();
    }
    if(action.equals("Close")){
      setVisible(false);
      dispose();
      oconnect.setCurrentFrame(scanbook.m2);
      date           = null;
      srunCards      = null;
      filiCards      = null;
      selections     = null;
      HTMLselections = null;
      output         = null;
    }
    if(action.equals("Save")){
      String fileName = defaultFile;   

      if(scanbook.m2 != null){
        String wtt = "";
        if(scanbook.m2.wt != null && scanbook.m2.wt.wtype != null ){
	  wtt = scanbook.m2.wt.wtype;
	}
        if(scanbook.m2.filisorted.getSelection().equals("Yes")){
	    //          System.out.println("Passe 10"+wtt);
	    if(!wtt.equals("RunsInfo")){
	       fileName = defaultFile.concat("$");
	    }
	}
      }
      saveFile(fileName+defaultType());
    }
    if(action.equals("Save as")){
      FileDialog fd = new FileDialog(this,"Fili cards file chooser",
                                     FileDialog.SAVE);
      fd.setDirectory(scanbook.defaultSaveDir);
      fd.setFile(defaultFile+defaultType());
      fd.setVisible(true);
      String filename = fd.getFile();           
      if(filename != null){
        String teststr = null;
        if(scanbook.m2 != null){
          teststr = scanbook.m2.filisorted.getSelection();
	}
        if(teststr != null && teststr.equals("Yes")){
	  if(filename.indexOf("$") == -1){
              String newFileName;
	      int pos = filename.indexOf(".");
            if(pos == -1){
	      newFileName = filename.concat("$");
	    }else{
	      newFileName = filename.substring(0,pos).concat("$");
              newFileName = newFileName.concat(filename.substring(pos)); 
	    }
            yesNo msg = new yesNo(
                              this," ");   
            msg.newline("You asked for fili sorted by LEP Energy");
            msg.newline("This may cause trouble in Alpha jobs");
            msg.newline("The best is to produce one cards file per energy");
            msg.newline("If you supply a file name which includes a $ sign,");
            msg.newline("the $ will be substituted by the Lep Energy.");
            msg.newline("I can do it for you :");
            msg.newline("");
            msg.newline("Would you like to use : "+newFileName+" ?");
            msg.display();
            if(!msg.no)filename = newFileName;
	  }
        }
        scanbook.defaultSaveDir = fd.getDirectory();
        filename = scanbook.defaultSaveDir+filename;
        setTitle(filename);
        saveFile(filename);
      }
    }
    if(action.equals("Save HTML")){
      FileDialog fd = new FileDialog(this,"Fili cards file chooser",
                                     FileDialog.SAVE);
      fd.setDirectory("./");
      fd.setFile("scanbook_selection.html");
      fd.setVisible(true);
      String filename = fd.getFile();           
      if(filename != null){
        filename = fd.getDirectory()+filename;
	//        defaultFile = filename; 
        setTitle(filename);
        saveHTML(filename);
      }
    }
    if(action.equals("DATE")){
	//      dateVisible = manipulateClist(date, dateVisible);
      date.setVisible(manipulateClist(date, date.isVisible()));
    }
    if(action.equals("FILI")){
	//      filiVisible = manipulateClist(filiCards, filiVisible);
      filiCards.setVisible(manipulateClist(filiCards, filiCards.isVisible()));
    }
    if(action.equals("SRUN")){
	//      srunVisible = manipulateClist(srunCards, srunVisible);
      srunCards.setVisible(manipulateClist(srunCards, srunCards.isVisible()));
    }
    if(action.equals("SELECTIONS")){
	//      selVisible = manipulateClist(selections, selVisible);
      selections.setVisible(
               manipulateClist(selections, selections.isVisible()));
    }
    if(action.equals("OUTPUT")){
	//      outputVisible = manipulateClist(output, outputVisible);
      output.setVisible(manipulateClist(output, output.isVisible()));
    }
    if(!action.equals("Close")){
      mypack();
    }
  }
  boolean manipulateClist(cardsList cl, boolean status){
      boolean newStatus = !status;
      cl.setVisible(newStatus);
      return newStatus;
  }
}

class cardsList extends TextArea implements fillable{

  int ncards = 0;
  int itemLength;
  String newline;
  StringBuffer buf = new StringBuffer();
  static int nominalWidth = 132;
  int maxLineWidth = 0;
  int bestWidth=0;
  cardsStore byLepEnergy= new cardsStore();

  cardsList(int scrollbarVisible){
     super("",2, nominalWidth, scrollbarVisible);
     newline = System.getProperty("line.separator");
     setVisible(true);
  }
  public String[] getAllEnergies(){
      String output[] = null;
      if(byLepEnergy != null){
	  output = byLepEnergy.getAllEnergies();
      }
      return output;
  }
  public String[] getAllEnergies(String[] listIn){
      String output[] = null;
      String toAdd[];
      Vector temp = new Vector();
      int i, j;
      boolean notExists;
      output = listIn;
      if(byLepEnergy != null){
	  toAdd = getAllEnergies();
          for(i=0; i<toAdd.length; i++){
	    notExists = true;
            for(j=0; j<listIn.length; j++){
		if(toAdd[i].equals(listIn[j])){
                   notExists = false;
                   break;
		}
	    }
            if(notExists) temp.addElement(toAdd[i]);
	  }
          int nNew = temp.size();
          int nOld = listIn.length;
          int n = nOld + nNew;
	  output = new String[n];
          for(i=0; i<nOld; i++){
	      output[i] = listIn[i];
	  }
          for(i=0; i<temp.size(); i++){
	      output[i+nOld] = (String)temp.elementAt(i);
	  }
      }
      return output;
  }
  public String getSelection(){
    return null;
  }
  public String getMenuName(){
    return "";
  }
  public void addItem(String sin, boolean select, boolean enabled){
    int pos;
    String s;
    if( (pos = sin.indexOf("^")) > -1){
      s = sin.substring(0,pos);
      //      if(byLepEnergy == null){
      //	  byLepEnergy = new cardsStore();
      //      }
    }else{
      s = sin;
    }
    if(ncards>0)buf.append(newline);
    buf.append(s);
    ncards++;
    itemLength = s.length() + 2;
    if(itemLength > maxLineWidth){
       maxLineWidth = itemLength;
       FontMetrics fm = getFontMetrics(getFont());
       bestWidth = fm.stringWidth(s+"  ");
    }
    if(byLepEnergy != null){
	byLepEnergy.addLine(sin);
    }
  }
  public void myResize(){
    setText(buf.toString());
  }
  public void myResize(int newWidth, int newNcol){
    int maxsiz = 15;
    setText(buf.toString());
    if(ncards < maxsiz){
      setRows(ncards);
    }else setRows(maxsiz);
    setColumns(newNcol);
    select(0,0);
    setSize(new Dimension(newWidth,getPreferredSize().height));
  }
  public void writeToFile(PrintWriter pw, String lepEnergy) 
                          throws IOException{
    if(isVisible()){
      if(lepEnergy == null){
	pw.println(getText());
      }else{
        String[] allLines = byLepEnergy.getContent(lepEnergy);
        for(int i=0; i<allLines.length; i++){
	  pw.println(allLines[i]);
	}
      }
    }
  }
  public void removeAll(){
    setText("");
    buf = new StringBuffer();
    ncards = 0;
    setRows(0);
    maxLineWidth = 0;
    bestWidth = 0;
    byLepEnergy = new cardsStore();
  }
  public Insets getInsets(){
    return new Insets(10,10,10,10);
  }
}

class cardsStore extends Vector{

  cardsStore(){
     super();
  }
  stringsStore findStore(String Ein){
     stringsStore theStore=null;
     stringsStore currentStore;
     for(int i=0; i<size(); i++){
	currentStore = (stringsStore)elementAt(i);
        if(currentStore.lepEnergy.equals(Ein)){
	    theStore = currentStore;
	}
     }
     if(theStore == null){
	 theStore = new stringsStore(Ein);
         addElement(theStore);
     }
     return theStore;
  }
  public void addLine(String s){
     int pos;
     String lepE;
     String newLine;
     if( (pos = s.indexOf("^")) > -1){
       lepE = s.substring(pos+1);
       newLine = s.substring(0, pos);
     }else{
       lepE = "";
       newLine = s;
     }
     stringsStore theStore = findStore(lepE);
     theStore.addString(newLine);
  }        
  public String[] getContent(String lepEnergy){
     stringsStore theStore = findStore(lepEnergy);
     return theStore.getContent();
  }
  public String[] getAllEnergies(){
      int n = size();
      String output[] = new String[n];
      for(int i=0; i<n; i++){
	  output[i] = new String(((stringsStore)elementAt(i)).lepEnergy);
      }
      return output;
  }
}

class stringsStore extends Vector{
  String lepEnergy;
  stringsStore(String energy){
     super();
     lepEnergy = energy;
  }  
  public void addString(String s){
     addElement(s);
  }
  String[] getContent(){
      int n = size();
      String output[] = new String[n];
      for(int i=0; i<n; i++){
	  output[i] = new String((String)elementAt(i));
      }
      return output;
  }
}

class yesNo{
  Dialog d;
  TextArea ta;
  int ncols;
  int nlines = 0;
  boolean yes;
  boolean no;
  yesNo(Frame f,String s){
     ncols = s.length();
     d = new Dialog(f,true);
     ta = new TextArea(s,10,80,TextArea.SCROLLBARS_NONE);
     ta.setEditable(false);
     ta.setFont(new Font("Courier",Font.BOLD,20));
     d.add("North",ta);
     Panel p = new Panel();
     Button bYes = new Button("Yes");
     Button bNo = new Button("No");
     bYes.addActionListener(new ActionListener(){
        public void actionPerformed(ActionEvent e) {
         yes = true;
         no = false;
         d.dispose();
   }});
     bNo.addActionListener(new ActionListener(){
        public void actionPerformed(ActionEvent e) {
         yes = false;
         no = true;
         d.dispose();
   }});
     p.add("West",bYes);
     p.add("East",bNo);
     d.add("South",p);
  }
  void newline(String s){
     int siz = s.length();
     if(siz > ncols){ncols = siz;}
     ta.append("\n");
     ta.append(s);
     nlines++;
  }
  void display(){
     ta.setColumns(ncols);
     ta.setRows(nlines+4);
     Toolkit.getDefaultToolkit().beep();
     d.pack();
     d.show();
  }
}


class page2 extends Frame{

  windowType wt = new windowType();
  final static String MCCHOICE = "MC Choice";
  final static String DATACHOICE = "Data Choice";
  Panel cardsmcdat;
  doubleRadioBox phyGrps; 
  choicePanel lepEnergies;
  choicePanel filisorted;
  choicePanel specialParticles;
  choicePanel runQuality; 
  choicePanel edirYesno;
  choicePanel useWsel;  
  radioMenu outputType;
  listDisplay mcDatasets;
  listDisplay processings;
  yearsIn yearselection;
  Panel p1;
  Panel p2;
  buttonsMenu buttons;
  fillable allMenus[];

  page2(oconnect c, Color fg, Color bg){
    super("SCANBOOK Java version");

    setBackground(bg);
    
// Separate into 2 columns

    GridBagLayout gbllr = new GridBagLayout();
    setLayout(gbllr);
    GridBagConstraints gbclr = new GridBagConstraints();
    gbclr.gridx = GridBagConstraints.RELATIVE;
    gbclr.gridheight = GridBagConstraints.REMAINDER;
    gbclr.fill = GridBagConstraints.BOTH;
    gbclr.weightx = 0.;
    gbclr.weighty = 1.;
    Panel pLeft = new Panel();
    Panel pRight = new Panel();
    gbllr.setConstraints(pLeft,gbclr);
    add(pLeft);
    gbllr.setConstraints(pRight,gbclr);
    add(pRight);

// Fill the right part

    lepEnergies = new choicePanel("energy_Lep", "Lep Energy", fg,bg); 
    filisorted = new choicePanel("filisorted", 
                               "Cards sorted by LEP energy ?", fg,bg); 
    filisorted.addItem("No");
    filisorted.addItem("Yes");

    edirYesno = new choicePanel("EdirYesno", "Access with EDIR ?", 
                                        fg,bg); 
    edirYesno.addItem("Yes");
    edirYesno.addItem("No");

    outputType  = new radioMenu("OutputType","Type of output",
                                        radioMenu.VERTICAL,fg,bg);
    buttons = new buttonsMenu("BackStopCont", fg,bg);
    buttons.addItem("BACK");
    buttons.addItem("GO");
    buttons.addItem("STOP");

    GridBagLayout gbl = new GridBagLayout();
    pRight.setLayout(gbl);
    GridBagConstraints gbc = new GridBagConstraints();

    gbc.gridx = GridBagConstraints.RELATIVE;
    gbc.gridy = GridBagConstraints.RELATIVE;
    gbc.gridwidth = GridBagConstraints.REMAINDER;
    gbc.fill = GridBagConstraints.HORIZONTAL;
    gbc.weightx = 1.;

    add(pRight,lepEnergies, gbl, gbc);
    add(pRight,filisorted,gbl,gbc);
    add(pRight,edirYesno, gbl, gbc);
    add(pRight,outputType, gbl, gbc);
    add(pRight,buttons, gbl, gbc);
  
// Now the left part

    cardsmcdat = new Panel();
    cardsmcdat.setLayout(new CardLayout());

    gbl.setConstraints(cardsmcdat,gbc);
    pLeft.add(cardsmcdat);

    Panel mcchoice = new Panel();

    Panel datachoice = new Panel();

    cardsmcdat.add(DATACHOICE,datachoice);
    cardsmcdat.add(MCCHOICE,mcchoice);

// MC data first
    mcchoice.setLayout(gbl);

    specialParticles = new choicePanel("specpar","Special particles",
                                               fg, bg);
    specialParticles.addItem("ANY");
    specialParticles.addItem("q qbar");
    add(mcchoice,specialParticles,gbl,gbc);

    mcDatasets = new listDisplay(
           "GALEPH  JULIA  MINI  Number of datasets","mcDatasets", fg,bg); 
    mcDatasets.addItem("*****************************");
    mcDatasets.addItem("*   No DATASETS AVAILABLE   *");
    mcDatasets.addItem("*****************************");
    add(mcchoice,mcDatasets,gbl,gbc);

// Then Real data 
// Make 2 panels vertically p1 and p2

    GridBagLayout gblDatac = new GridBagLayout();
    datachoice.setLayout(gblDatac);
    p1 = new Panel();
    p2 = new Panel();
    GridBagConstraints gbch = new GridBagConstraints();
    gbch.gridx = GridBagConstraints.RELATIVE;
    gbch.gridy = GridBagConstraints.RELATIVE;
    gbch.fill = GridBagConstraints.VERTICAL;
    gbch.weighty = 1.;

    add(datachoice,p1,gblDatac,gbch);
    gbch.gridwidth = GridBagConstraints.REMAINDER;
    add(datachoice,p2,gblDatac,gbc);

//fill p1 with run quality

    p1.setLayout(gbl);
    runQuality = new choicePanel("Runquality","Run quality", fg,bg); 
    runQuality.addItem("All Runs");
    add(p1,runQuality,gbl,gbc);

    phyGrps = new doubleRadioBox("PhysGroups","PhysGroups", 
                                      doubleRadioBox.VERTICAL, fg, bg);
    phyGrps.setVisible(false);
    add(p1,phyGrps,gbl,gbc);
    useWsel = new choicePanel("useWsel","WW bad runs",fg,bg);  
    //    useWsel.addItem("Ignore");
    //    useWsel.addItem("Apply");
    useWsel.addItem("View");
    if(scanbook.osName.indexOf("Windows") == -1 ||
       scanbook.netscaperun){
      useWsel.addItem("Open web page");
    }
    add(p1,useWsel,gbl,gbc);

//fill p2 with    and lep energies

    p2.setLayout(gbl);

    processings = new listDisplay(
           "Processing   # of            Dates of          Version #    Compl.\n"+
           "   Level    Datasets        Processing         JUL   MINI  Proc. ?\n",
           "processings", fg,bg); 
    //    processings.addItem("Last ................");
    //    processings.addItem("Previous ...........");
    add(p2,processings,gbl,gbc);

    yearselection = new yearsIn("yearselection", fg, bg);
    add(p2,yearselection,gbl,gbc);

    setAspect();

    allMenus = new fillable[] { 
       phyGrps, 
       lepEnergies,
       filisorted,
       specialParticles,
       runQuality,
       outputType,
       mcDatasets,
       processings,
       edirYesno,
       //       useWsel
    };
  }
  void fillAll(oconnect c){
    c.fillList(new fillable[] {
	   lepEnergies,specialParticles,mcDatasets,outputType,
           runQuality,processings,phyGrps, wt,
           scanbook.m1.selectYear
    });
    setAspect();
  }
  void setAspect(){
    if(scanbook.m1.typedata.getSelection().equals("Real DATA")){
       filisorted.setVisible(true);
       switchcardsMcd(DATACHOICE);
    }else{
       filisorted.setVisible(false);
       switchcardsMcd(MCCHOICE);
    }
    yearselection.setVisible(false);
    processings.setVisible(true);
// Never show output type 
    outputType.setVisible(false);
    yearselection.setVisible(false);
    edirYesno.setVisible(true);
    String action = scanbook.m1.whatyouwant.getSelectedAction();
    if(action != null && action.equals("Calib")){
       edirYesno.setVisible(false);
    }
    if(wt.getSelection().equals("RunsInfo")){
       processings.setVisible(false);
       outputType.setVisible(false);
       edirYesno.setVisible(false);
    }
// Decide if we need to show the WW selection button (only in case of WW Phys.
    if(runQuality.getSelection().startsWith("WW")){
	useWsel.setVisible(true);
    }else{
	useWsel.setVisible(false);
    }

    action = scanbook.m1.datasetType.getSelectedAction();
    if(action != null && action.equals("RawData")){
       processings.setVisible(false);
       edirYesno.setVisible(false);
    }
  }
  void add(Container cont, Component comp, 
             GridBagLayout layout, GridBagConstraints cnst){
    layout.setConstraints(comp,cnst);
    cont.add(comp);
  }
  public void switchcardsMcd(String selection){
     ((CardLayout)cardsmcdat.getLayout()).show(cardsmcdat,selection);
  }
  void sendSelections(oconnect c){
    for(int i=0; i<allMenus.length; i++){
      c.sendSelection(allMenus[i]);
    }
  }
  void sendSelections(fillable ll, String header, String sep, String endStr,
                     boolean encode, boolean ending){
    for(int i=0; i<allMenus.length; i++){
      String mn  = allMenus[i].getMenuName();
      String sel = allMenus[i].getSelection();
      if(mn != null && sel != null){
	 String val = allMenus[i].getSelection();
         String nam = allMenus[i].getMenuName();
         if(encode){
	     val = URLEncoder.encode(val);
	     nam = URLEncoder.encode(nam);
	 }
         ll.addItem(header+nam+
                 sep+val+endStr,
                  false,ending);
      }
    }
  }
  boolean verifyInput(){
    if(scanbook.m1.typedata.getSelection().equals("Real DATA")){
      if(processings.getSelection() != null)return true;
      return false;
    }else{
      //      if(mcDatasets.getSelection() != null)return true;
      return true;
    }
  }
  public void relocate(){
    setLocation(10,50);
  }
}

class dummyfillable implements fillable{
    public void addItem(String s, boolean select, boolean enabled){}
    public void removeAll(){}
    public String getSelection(){
      return "";
    }
    public String getMenuName(){
      return "";
    }
}

class windowType implements fillable{
  String wtype = "";
  public void addItem(String s, boolean select, boolean enabled){
    wtype = s;
  }
  public void removeAll(){
    wtype = "";
  }
  public String getSelection(){
    return wtype;
  }
  public String getMenuName(){
    return "";
  }
}
  
class menu1 extends Frame implements ActionListener{

  MenuBar mb = new MenuBar();
  Menu optMenu = new Menu("Options");
  Menu helpMenu = new Menu("Help");

  Point currentPosition;

  Panel main;
  Panel typeInstitute;
  Panel dataset = new Panel();
  //  Panel buttons = new Panel();
  Panel cardsNormRun;
  Panel cardsrofy;
  Panel cardsmcdat;
  Panel normalPanel;
  runCartIn runCartPanel;
  listDisplay kingalCond;
  final static String ROF = "Run or Fill";
  final static String BYYEAR = "By Year";
  final static String IMPATIENT = "ImpatientStreams";
  final static String MCCHOICE = "MC Choice";
  final static String DATACHOICE = "Data Choice";
  final static String NORMALPANEL = "Normal Panel";
  final static String RUNCARTPANEL = "Run Cart Panel";
  buttonsMenu buttons; 

  radioMenu datasetType;
  radioMenu whatyouwant; 
  runOrFill rof;
  choicePanel imp;
  choicePanel inst;
  choicePanel selectYear;
  choicePanel selectDataBy;
  choicePanel typedata; 
  mcChoice mcchoice;
  choicePanel kinMasses;

  fillable allMenus[];

  menu1(Color fg, Color bg) {
    super("SCANBOOK Java version");
    setMenuBar(mb);    
    mb.add(optMenu);
    mb.setHelpMenu(helpMenu);
    optMenu.add("Debug ON");
    optMenu.add("Debug OFF");
    optMenu.add("Preferences");
    optMenu.add("Statistics");
    optMenu.addActionListener(this);

    helpMenu.add("Install");
    helpMenu.add("New facilities");
    helpMenu.addActionListener(this);

    setBackground(bg);
    
    main = new Panel();
    add(main);
    buildmain(fg,bg);
    scanbook.defaultCursor = new Cursor(Cursor.DEFAULT_CURSOR);
  }
  void rebuildmain(Color fg, Color bg){
    remove(main);
    main = new Panel();
    add(main);
    buildmain(fg,bg);
  }
  void buildmain(Color fg, Color bg){

    cardsNormRun = new Panel();
    cardsmcdat = new Panel();
    normalPanel = new Panel();

// Separate into 2 columns

    GridBagLayout gbllr = new GridBagLayout();
    main.setLayout(gbllr);
    GridBagConstraints gbclr = new GridBagConstraints();
    gbclr.gridx = GridBagConstraints.RELATIVE;
    gbclr.gridheight = GridBagConstraints.REMAINDER;
    gbclr.fill = GridBagConstraints.BOTH;
    gbclr.weightx = 0.;
    gbclr.weighty = 1.;
    Panel pLeft = new Panel();
    Panel pRight = new Panel();
    gbllr.setConstraints(pLeft,gbclr);
    main.add(pLeft);
    gbllr.setConstraints(pRight,gbclr);
    main.add(pRight);

// Fill the right part

    GridBagLayout gblr = new GridBagLayout();
    pRight.setLayout(gblr);

    GridBagConstraints gbcr = new GridBagConstraints();
    buildconstraints(gbcr, 1, 0, 
                     GridBagConstraints.REMAINDER);
    gbcr.gridx = GridBagConstraints.RELATIVE;
    gbcr.anchor = GridBagConstraints.NORTH;

    kingalCond = new listDisplay(" POTs MINIs Condition explanation "+
                                 "                                  ",
                                     "Kingal_conds", fg, bg);
    //    kingalCond.addItem("Conditions for Kingal generators bbbbbbbbbb");
    kingalCond.showIfNeeded();
    gblr.setConstraints(kingalCond,gbcr);
    pRight.add(kingalCond);     

    kinMasses = new choicePanel("kinMass","Mass",fg,bg);
    gblr.setConstraints(kinMasses,gbcr);
    pRight.add(kinMasses);     
    kinMasses.setVisible(false);

//  Below is all for the left part of m1

    GridBagLayout gbl = new GridBagLayout();
    pLeft.setLayout(gbl);

    GridBagConstraints gbc = new GridBagConstraints();
    buildconstraints(gbc, 1, 0, 
                     GridBagConstraints.REMAINDER);
    typeInstitute = new Panel();
    gbl.setConstraints(typeInstitute,gbc);
    pLeft.add(typeInstitute);
    typeInstitute.setLayout(new GridLayout(1,0));
    typedata = new choicePanel("typedat", "Data : ",fg, bg);
    fillTypeData();
    typeInstitute.add(typedata);

    inst = new choicePanel("institute", "Institute",fg, bg);
    typeInstitute.add(inst);

    buildconstraints(gbc, 0, GridBagConstraints.RELATIVE, 
                     GridBagConstraints.REMAINDER);

    cardsmcdat = new Panel();
    cardsmcdat.setLayout(new CardLayout());
    gbl.setConstraints(cardsmcdat,gbc);
    pLeft.add(cardsmcdat);

    mcchoice = new mcChoice(fg, bg);
    Panel datachoice = new Panel();
    GridBagLayout gblDatac = new GridBagLayout();
    datachoice.setLayout(gblDatac);

    cardsmcdat.add(DATACHOICE,datachoice);
    cardsmcdat.add(MCCHOICE,mcchoice);


    selectDataBy = new choicePanel("selby", "Select data by",fg, bg);
    selectDataBy.addItem("YEAR");
    selectDataBy.addItem("RUN(s)");
    selectDataBy.addItem("FILL(s)");
    gblDatac.setConstraints(selectDataBy,gbc);
    datachoice.add(selectDataBy);

    cardsrofy = new Panel();
    cardsrofy.setLayout(new CardLayout());


    gblDatac.setConstraints(cardsNormRun,gbc);
    datachoice.add(cardsNormRun);
    cardsNormRun.setLayout(new CardLayout());
    cardsNormRun.add(NORMALPANEL,cardsrofy);
    runCartPanel = new runCartIn("RunOrCart", fg, bg);
    cardsNormRun.add(RUNCARTPANEL,runCartPanel);
    imp = new choicePanel(IMPATIENT,IMPATIENT,fg,bg);
    imp.addItem("1999");
    cardsNormRun.add(IMPATIENT, imp); 



    selectYear = new choicePanel("DataYear", "Select year",fg, bg);
    cardsrofy.add(BYYEAR, selectYear);

    rof = new runOrFill("runorfill", fg, bg);
    cardsrofy.add(ROF, rof); 


    whatyouwant = new radioMenu("wantwhat","what you want",
                                        radioMenu.VERTICAL,fg,bg);
    gblDatac.setConstraints(whatyouwant,gbc);
    datachoice.add(whatyouwant);

    datasetType = new radioMenu("data_type", "Radiobox",
                                        radioMenu.HORIZONTAL,fg,bg);
        gbl.setConstraints(datasetType,gbc);
        pLeft.add(datasetType);

    buttons = new buttonsMenu("stopcont", fg,bg);
    buttons.addItem("RELOAD");
    buttons.addItem("STOP");
    buttons.addItem("CONTINUE");
    //    buttons.setEnabled("CONTINUE",false);
    gbl.setConstraints(buttons,gbc);
    pLeft.add(buttons);
    allMenus = new fillable[] { 
// Real data
      typedata,
      inst,
      whatyouwant,
      datasetType,
      selectYear,
      rof,
      selectDataBy,
      runCartPanel,
// MC data
      mcchoice.kinlist,
      kingalCond,
      mcchoice.selectYear,  
      kinMasses
    };
  }
  void fillTypeData(){
      typedata.removeAll();
      typedata.addItem("Real DATA");
      typedata.addItem("MC DATA");
  }
  void sendSelections(oconnect c){
    for(int i=0; i<allMenus.length; i++){
      c.sendSelection(allMenus[i]);
    }
  }
  void sendSelections(fillable ll, String header, String sep, String endStr,
                     boolean encode, boolean ending){
    for(int i=0; i<allMenus.length; i++){
      String mn  = allMenus[i].getMenuName();
      String sel = allMenus[i].getSelection();
      if(mn != null && sel != null){
	 String val = allMenus[i].getSelection();
         String nam = allMenus[i].getMenuName();
         if(encode){
	     val = URLEncoder.encode(val);
	     nam = URLEncoder.encode(nam);
	 }
         ll.addItem(header+nam+
                 sep+val+endStr,
                  false,ending);
      }
    }
  }
    /*
  void sendSelections(fillable ll, String header, boolean ending){
    for(int i=0; i<allMenus.length; i++){
      String mn  = allMenus[i].getMenuName();
      String sel = allMenus[i].getSelection();
      if(mn != null && sel != null){
         ll.addItem(header+allMenus[i].getMenuName()+
                 "=>"+allMenus[i].getSelection(),
                  false,ending);
      }
    }
  }
    */
  void setAspect(){
    String action = whatyouwant.getSelectedAction();
    if(action != null && action.equals("RunorCart")){
      switchcards3(RUNCARTPANEL);
    }else{
      switchcards3(NORMALPANEL);
    }
    if(typedata.getSelection().equals("MC DATA")){
      kingalCond.showIfNeeded();
      if(kingalCond.isVisible()){
         kinMasses.showIfNeeded();
      }else{
         kinMasses.setVisible(false);
      }
    }else{
      kingalCond.setVisible(false);
      kinMasses.setVisible(false);
    }
  }
  public void packshow(){
    pack();
    relocate();
    show();
  }
  public void storeLocation(){
      /*
// IF you activate the 2 lines below, the window does not come back to
//    the same place when you relocate 
//    Advice from experts is to use Swing !
    currentPosition = getLocation();
    printPosition();
      */
  }
  void printPosition(){
     System.out.println("Current Position = "+
                       String.valueOf(currentPosition.x) + " "+
                       String.valueOf(currentPosition.y)); 
  }
  public void relocate(){
    if(currentPosition != null){
// Does not work because of problem with storeLocation
	//       printPosition();
	//       setLocation(currentPosition);
    }else{
       setLocation(10,50);
    }
  }
  public void switchcards1(String selection){
     ((CardLayout)cardsrofy.getLayout()).show(cardsrofy,selection);
  }
  public void switchcards2(String selection){
     ((CardLayout)cardsmcdat.getLayout()).show(cardsmcdat,selection);
  }
  public void switchcards3(String selection){
     ((CardLayout)cardsNormRun.getLayout()).show(cardsNormRun,selection);
     selectDataBy.setVisible(selection.equals(NORMALPANEL));
  }
  void buildconstraints(GridBagConstraints gbc, int gx, int gy, int gw){
    gbc.gridx = GridBagConstraints.RELATIVE;
    gbc.gridy = GridBagConstraints.RELATIVE;
    gbc.gridwidth = gw;
    //    gbc.anchor = GridBagConstraints.WEST;
    gbc.fill = GridBagConstraints.HORIZONTAL;
    gbc.weightx = 1.;
  }
  boolean verifyInput(){
    if(typedata.getSelection().equals("Real DATA"))return true;
    if(mcchoice.kinlist.getSelection() != null)return true;
    return false;
  }
  public void actionPerformed(ActionEvent e) {
    String action = e.getActionCommand(); 
    if(action.equals("Debug ON"))scanbook.dbg.setlevel(1);  
    if(action.equals("Debug OFF"))scanbook.dbg.setlevel(0);  
    if(action.equals("Preferences"))scanbook.scbProp.editProperties();  
    if(action.equals("Statistics"))scanbook.showStats();  

    if(action.equals("Install")){
	scanbook.openWeb(this,
                    "http://alephwww.cern.ch/scanbook/scanbook.html"); 
    }
    if(action.equals("New facilities")){
	scanbook.openWeb(this,
                    "http://alephwww.cern.ch/scanbook/newfacilities.html"); 
    }
  }
}
class mcChoice extends Panel {
    //    kinList kinlist;
    listDisplay kinlist;
    choicePanel  selectYear;
    mcChoice(Color fg, Color bg){
      super();
      GridBagLayout gbl = new GridBagLayout();
      setLayout(gbl);
      GridBagConstraints gbc = new GridBagConstraints();
      gbc.gridx = GridBagConstraints.RELATIVE;
      gbc.gridy = GridBagConstraints.RELATIVE;
      gbc.gridwidth = GridBagConstraints.REMAINDER;
      gbc.fill = GridBagConstraints.HORIZONTAL;
      gbc.weightx = 1.;
      selectYear = new choicePanel("McYear", "Select year",fg, bg);
      gbl.setConstraints(selectYear,gbc);
      add(selectYear);
      //      kinlist = new kinList("KinList", fg, bg);
      kinlist = new listDisplay(             
             " KINGAL           ALEPH          Number of datasets\n"+
             "  code             name          POT           MINI \n",
             "Kinlist", fg, bg);
      gbl.setConstraints(kinlist,gbc);
      add(kinlist);
    }
}

class runCartIn extends Panel
            implements fillable{
  String menuName;
  String verifiedText;
  //  List runslist = new List(12);
  Panel mainPanel = new Panel();
  TextField text = new TextField();
  Vector byYear = new Vector();

  runCartIn(String m, Color fg, Color bg) {
    super();
    setFont(scanbook.myFont);
    menuName = m;
    GridBagLayout gblmain =  new GridBagLayout();
    setLayout(gblmain);
    GridBagConstraints gbcmain = new GridBagConstraints();
    gbcmain.fill = GridBagConstraints.HORIZONTAL;
    gbcmain.weightx = 1;
    gblmain.setConstraints(mainPanel,gbcmain);
    add(mainPanel);
    mainPanel.setBackground(fg);

    GridBagLayout gbl =  new GridBagLayout();
    mainPanel.setLayout(gbl);
    GridBagConstraints gbc = new GridBagConstraints();
    gbc.gridx = 0;
    gbc.gridy = GridBagConstraints.RELATIVE;
    gbc.fill = GridBagConstraints.BOTH;
    gbc.weightx = 1;
    gbc.weighty = 0;

    Label l = new Label("   Please Enter Run number or Cartridge name[.file nb]");
    l.setFont(scanbook.myFont);
    gbl.setConstraints(l,gbc);
    mainPanel.add(l);
    gbl.setConstraints(text,gbc);
    mainPanel.add(text);
    /*
    text.addTextListener(new TextListener(){
       public void textValueChanged(TextEvent e) {
       scanbook.callbacks(menuName,text.getText());
       }
    });
    */
  }
  public String getSelection(){
    String test = scanbook.m1.selectDataBy.getSelection();
    //    System.out.println("******** test *" +test+"*");
    if(!isVisible()) return "";
    if(verifyText()){
      return verifiedText;
    }
    return null;
  }
  boolean verifyText(){
    boolean output = true;
    boolean thereisdot = false;
    String localString = text.getText().trim();
    String hdr = "";
    boolean isrun = false;
    boolean iscart = false;

    errorMessage msg = new errorMessage(
                   scanbook.m1,"Wrong input :");   
    msg.newline("  ");
    msg.newline(localString);
    msg.newline("  ");

    int nchars = 0;
    if(localString != null)nchars = localString.length();
// Should be at least 4 characters :
    if(nchars < 4){
        msg.newline("Too short !");
    }
//  Is it a run ?
    if(nchars == 5){
	isrun = true;
        for(int i=0; i<nchars;i++){
          if(!Character.isDigit(localString.charAt(i))) isrun = false;
        }
        if(isrun){
// Run nb should be > 4000 (below is MC)
          int run = Integer.parseInt(localString.trim());          
          if(run < 4000){
	     msg.newline("Run number should be < 4000");
             isrun = false; 
	  }
	}        
      }
//  If it is not a run, maybe it is a CART
      if(nchars >= 6 && !isrun){ 
        iscart = true;       
        int ifirst = 0;
        if(Character.isLetter(localString.charAt(0)) &&
           Character.isLetter(localString.charAt(1))) {
           ifirst = 2;
        }else if(Character.isLetter(localString.charAt(0))) {
           ifirst = 1;
        }else{
	    iscart = false;
	}
//
// Verify that there are a total of 6 caracters, the first 1 or 2
// are letters; the rest must be digits
//
        int nend = localString.indexOf('.');
        if(nend == -1)nend = nchars;
        else thereisdot = true;
        if(nend != 6)iscart = false;
        if(iscart){
          for(int i=ifirst; i<nend;i++){
            if(!Character.isDigit(localString.charAt(i))){
               iscart = false;
	    }
	  }
	}
        if(thereisdot){
//
// If there was a '.', it must be followed by 1 to 3 digits
//
          ifirst = nend + 1;
          if(iscart && (nchars > ifirst + 3 ||
                        nchars < ifirst + 1 )) iscart = false;
          if(iscart){
            for(int i=ifirst; i<nchars;i++){
              if(!Character.isDigit(localString.charAt(i))){ 
                iscart = false;
	      }
            }
	  }
	}
    }
    if(isrun){ hdr = "RUN";
    }else if(iscart){ hdr = "CRT";
    }else output = false;
    if(output){ verifiedText = hdr+" "+localString;
    }else{
        msg.newline("Please correct");
        msg.display();
    }
    msg = null;
    return output;
  }
  public String getMenuName(){
    return menuName;
  }
  public void addItem(String lbl, boolean select, boolean enabled){
  }
  public Insets getInsets(){
    return new Insets(10,10,10,10);
  }
  public void removeAll(){}
}

class yearsIn extends Panel
            implements fillable{
  String menuName;
  String verifiedText;
  Panel mainPanel = new Panel();
  TextField text = new TextField();
  Vector byYear = new Vector();

  yearsIn(String m, Color fg, Color bg) {
    super();
    setFont(scanbook.myFont);
    menuName = m;
    GridBagLayout gblmain =  new GridBagLayout();
    setLayout(gblmain);
    GridBagConstraints gbcmain = new GridBagConstraints();
    gbcmain.fill = GridBagConstraints.HORIZONTAL;
    gbcmain.weightx = 1;
    gblmain.setConstraints(mainPanel,gbcmain);
    add(mainPanel);
    mainPanel.setBackground(fg);

    GridBagLayout gbl =  new GridBagLayout();
    mainPanel.setLayout(gbl);
    GridBagConstraints gbc = new GridBagConstraints();
    gbc.gridx = 0;
    gbc.gridy = GridBagConstraints.RELATIVE;
    gbc.fill = GridBagConstraints.BOTH;
    gbc.weightx = 1;
    gbc.weighty = 0;

    TextArea l = new TextArea(
                 "  Selection on date of data taking\n"+
                 "  Please reply : \n"+
                 " > yymmdd        to select AFTER  date yymmdd\n"+
                 " < yymmdd        to select BEFORE date yymmdd\n"+
                 "   yymmdd/YYMMDD to select BETWEEN yymmdd and YYMMDD\n"+
                 "   Please enter your answer.\n"+
                 "   blank  = NO SELECTION on date");
    l.setEditable(false);
    l.setFont(scanbook.myFont);
    gbl.setConstraints(l,gbc);
    mainPanel.add(l);
    gbl.setConstraints(text,gbc);
    mainPanel.add(text);
    text.addTextListener(new TextListener(){
       public void textValueChanged(TextEvent e) {
       scanbook.callbacks(menuName,text.getText());
       }
    });
  }
  public String getSelection(){
    String test = scanbook.m1.selectDataBy.getSelection();
    //    System.out.println("******** test *" +test+"*");
    if(!isVisible()) return "  ";
    if(verifyText()){
      return verifiedText;
    }
    return null;
  }
  boolean verifyText(){
    boolean output = true;
    String localString = text.getText().trim();
    String hdr = "RUN";
    if(output){ verifiedText = hdr+" "+localString;
    }else{
        errorMessage msg = new errorMessage(
                        scanbook.m1,"Wrong input :");   
        msg.newline("  ");
        msg.newline(localString);
        msg.newline("  ");
        msg.newline("Please correct");
        msg.display();
    }
    return output;
  }
  public String getMenuName(){
    return menuName;
  }
  public void addItem(String lbl, boolean select, boolean enabled){
  }
  public Insets getInsets(){
    return new Insets(10,10,10,10);
  }
  public void removeAll(){}
}

class kinList_dummy extends Panel
            implements ItemListener, fillable{

  List kinlist = new List(20);
  Panel mainPanel = new Panel();
  String menuName;
  kinList_dummy(String m, Color fg, Color bg) {
    super();
    setFont(scanbook.myFont);
    menuName = m;
    GridBagLayout gblmain =  new GridBagLayout();
    setLayout(gblmain);
    GridBagConstraints gbcmain = new GridBagConstraints();
    gbcmain.fill = GridBagConstraints.HORIZONTAL;
    gbcmain.weightx = 1;
    gblmain.setConstraints(mainPanel,gbcmain);
    add(mainPanel);
    mainPanel.setBackground(fg);

    GridBagLayout gbl =  new GridBagLayout();
    mainPanel.setLayout(gbl);
    GridBagConstraints gbc = new GridBagConstraints();
    gbc.gridx = 0;
    gbc.gridy = GridBagConstraints.RELATIVE;
    gbc.fill = GridBagConstraints.BOTH;
    gbc.weightx = 1;
    gbc.weighty = 0;
    /*
    Label l1 = new Label(" KINGAL           ALEPH           Number of datasets ");
    Label l2 = new Label("  code             name      KIN  RAW  POT  DST MINI NANO");
    l1.setFont(scanbook.myFont);
    gbl.setConstraints(l1,gbc);
    mainPanel.add(l1);
    l2.setFont(scanbook.myFont);
    gbl.setConstraints(l2,gbc);
    mainPanel.add(l2);
    */
    TextArea t = new TextArea(
             " KINGAL           ALEPH          Number of datasets\n"+
             "  code             name        KIN  RAW  POT  DST MINI NANO\n",
             3,50,TextArea.SCROLLBARS_NONE);
    t.setFont(scanbook.myFont);
    t.setEditable(false);
    gbl.setConstraints(t,gbc);
    mainPanel.add(t);

    gbl.setConstraints(kinlist,gbc);
    mainPanel.add(kinlist);
    kinlist.addItemListener(this);
  }
  //  public void sendSelection(oconnect c){
  //    c.put_value(menuName,getSelection());
  //  }
  public String getSelection(){
    return kinlist.getSelectedItem();
  }
  public String getMenuName(){
    return menuName;
  }
  public void addItem(String lbl){
    addItem(lbl,false, true);
  }
  public void addItem(String lbl, boolean select, boolean enabled){
    kinlist.addItem(lbl);
    if(select){
      kinlist.select(kinlist.getItemCount()-1);
    }
  }
  public void removeAll(){
    kinlist.removeAll();
  }
  public Insets getInsets(){
    return new Insets(10,10,10,10);
  }
  public void itemStateChanged(ItemEvent e) {
        String lbl = kinlist.getItem(((Integer)(e.getItem())).intValue());
	//      System.err.println("3");
        scanbook.callbacks(menuName,lbl);
  }
}

class choicePanel extends Panel 
                implements ItemListener, fillable{

  String menuName;
  Panel mainPanel = new Panel();
  Choice c = new Choice();
  choicePanel(String m, String label, Color fg, Color bg) {
    super();
    setFont(scanbook.myFont);
    c.setFont(scanbook.myFont);
    menuName = m;
    GridBagLayout gblmain =  new GridBagLayout();
    setLayout(gblmain);
    GridBagConstraints gbcmain = new GridBagConstraints();
    gbcmain.fill = GridBagConstraints.HORIZONTAL;
    gbcmain.weightx = 1;
    gblmain.setConstraints(mainPanel,gbcmain);
    add(mainPanel);
    mainPanel.setBackground(fg);
    GridBagLayout gbl =  new GridBagLayout();
    mainPanel.setLayout(gbl);
    GridBagConstraints gbc = new GridBagConstraints();
    gbc.gridy = 0;
    gbc.gridx = GridBagConstraints.RELATIVE;
    gbc.fill = GridBagConstraints.NONE;
    gbc.weightx = 0;

    Label l = new Label(label);
    gbl.setConstraints(l,gbc);
    gbl.setConstraints(c,gbc);
    mainPanel.add(l);
    mainPanel.add(c);
    c.setBackground(fg);
    l.setBackground(fg);
    Panel preste = new Panel();
    //    preste.setBackground(fg);
    //    preste.setBackground(Color.red);
    gbc.fill = GridBagConstraints.HORIZONTAL;
    gbc.weightx = 1;
    gbl.setConstraints(preste,gbc);
    mainPanel.add(preste);
    c.addItemListener(this);
  }
  //  public void sendSelection(oconnect c){
  //    c.put_value(menuName,getSelection());
  //  }
  public String getSelection(){
      if(c.getSelectedItem() != null){
         return c.getSelectedItem();
      }else{
	 return "";
      }
  }
  public String getMenuName(){
    return menuName;
  }
  public void addItem(String lbl){
    addItem(lbl,false,true);
  }
  public void addItem(String lbl, boolean select, boolean enabled){
    c.addItem(lbl);
    c.setFont(scanbook.myFont);
    if(select){
      c.select(c.getItemCount()-1);
    }
  }
  public void showIfNeeded(){
    int N = c.getItemCount();
    if(N > 0){
	setVisible(true);
    }else{
	setVisible(false);
    }
  }
  public void removeAll(){
    c.removeAll();
  }
  public Insets getInsets(){
    return new Insets(10,10,10,10);
  }
  public void itemStateChanged(ItemEvent e) {
        String lbl = (String)e.getItem();
        scanbook.callbacks(menuName,lbl);
  }
}

class radioMenu extends Panel
                implements ItemListener, fillable{
  static int HORIZONTAL = 0;
  static int VERTICAL = 1;
  myCheckbox currentChoice;
  String menuName;
  CheckboxGroup box = new CheckboxGroup();
  Vector allBoxes = new Vector();

  Panel mainPanel = new Panel();
  int orientation;

  radioMenu(String m, String label, int ori, Color fg, Color bg) {
    super();
    setFont(scanbook.myFont);
    menuName = m;
    setLayout(new GridLayout(1,1));
    add(mainPanel);
    mainPanel.setBackground(fg);

    orientation = ori;

    //    setBackground(fg);
    if(orientation == HORIZONTAL){
       mainPanel.setLayout(new GridLayout(1,0));
    }
    if(orientation == VERTICAL){
       mainPanel.setLayout(new GridLayout(0,1));
    }

  }
  //  public void sendSelection(){
  //  }
  public String getSelection(){
    if(currentChoice != null){
      return currentChoice.getLabel();
    }else{
      return null;
    }
  }
  public String getSelectedAction(){
    String returnValue = null;
    if(currentChoice != null && currentChoice.action != null){
        return currentChoice.action.trim();
    }
    return null;
  }
  public String getMenuName(){
    return menuName;
  }
  public void addItem(String lbl){
    addItem(lbl, false, true);
  }
  public void addItem(String lbl, boolean state, boolean enabled){

    Panel localPanel = new Panel();
    mainPanel.add(localPanel);

    GridBagLayout gbl =  new GridBagLayout();
    localPanel.setLayout(gbl);
    GridBagConstraints gbc = new GridBagConstraints();
    gbc.fill = GridBagConstraints.HORIZONTAL;

    myCheckbox c = new myCheckbox(lbl,state,box);
    gbc.weightx = 0;
    gbl.setConstraints(c,gbc);
    localPanel.add(c);

    Panel space = new Panel();
    gbc.weightx = 1;
    gbl.setConstraints(space,gbc);
    localPanel.add(space);
    c.addItemListener(this);
    allBoxes.addElement(c);
    if(state){
        c.setForeground(Color.red);
        currentChoice = c;        
    }
    if(!enabled){
      c.setEnabled(false);
    }
  }
  public Insets getInsets(){
    return new Insets(10,10,10,10);
  }
  public void removeAll(){
    mainPanel.removeAll();    
    allBoxes.removeAllElements();
    currentChoice = null;
  }
  public void itemStateChanged(ItemEvent e) {
      String lbl = (String)e.getItem();
      setTheChoice((myCheckbox)e.getSource(), lbl, true);
  }
  public void setTheChoice(myCheckbox newChoice, String lbl, boolean doCallb){
     if(currentChoice != null){
        currentChoice.setForeground(Color.black);
        currentChoice.setState(false);          
     }
     currentChoice = newChoice;        
     currentChoice.setForeground(Color.red);
     currentChoice.setState(true);          
     if(doCallb)scanbook.callbacks(menuName,lbl);
     String currentAction = currentChoice.action;
     if(currentAction != null && doCallb){
       scanbook.callbacks(menuName+"_action",currentAction);
     }
  }
  public void disableSome(String lbls[]){
        int n = allBoxes.size();
        int j;
        int ndisable = lbls.length;
        for(int i=0;i<n;i++){
            myCheckbox cbox = (myCheckbox)allBoxes.elementAt(i);
            cbox.setEnabled(true);
	    String s = cbox.getLabel();
            for(j=0;j<ndisable;j++){
		if(s.equals(lbls[j]))cbox.setEnabled(false);
	    }
	    if(cbox.isEnabled()){
		setTheChoice(cbox, s, false);
	    }
	}
  }
}

class myCheckbox extends Checkbox{
  String action;
  myCheckbox(String lbl, boolean state, CheckboxGroup group){
      super(lbl);
      setState(state);
      setCheckboxGroup(group);
      int i = lbl.indexOf('^');
      if(i > 0){
         action = lbl.substring(i+1);
         String newLabel = lbl.substring(0,i);
         setLabel(newLabel);
      }
  }
}








