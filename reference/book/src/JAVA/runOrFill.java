import java.io.*;
import java.text.*;
import java.awt.*;   
import java.awt.List;
//import java.awt.event.*;         // New event model.
import java.awt.event.TextListener;
import java.awt.event.TextEvent;
import java.awt.event.ItemListener;
import java.awt.event.ItemEvent;
import java.awt.event.ActionListener;
import java.awt.event.ActionEvent;
import java.util.*;

public class runOrFill extends Panel
            implements ItemListener, fillable{

  String menuName;
  String verifiedText;
  List runslist = new List(12);
  Panel mainPanel = new Panel();
  TextField text = new TextField();
  Vector byYear = new Vector();

  runOrFill(String m, Color fg, Color bg) {
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

    Label l = new Label("          Year    First run  Last run"+
                        "  First fill  Last fill");
    l.setFont(scanbook.myFont);
    gbl.setConstraints(l,gbc);
    mainPanel.add(l);

    gbl.setConstraints(runslist,gbc);
    mainPanel.add(runslist);
    runslist.addItemListener(this);

    Label l2 = new Label("Your choice N1/N2 or N1,N2,N3 ...");
    gbl.setConstraints(l2,gbc);
    mainPanel.add(l2);

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
    if(verifyText()){
      return verifiedText;
    }
    return null;
  }
  boolean verifyText(){
    verifiedText = "";
    String trimmedText = text.getText().trim();
    String localText = text.getText().trim();
    String finalText = "";
    String begin, end;
    String errMsg = "Syntax Error";
    int i;
    if(scanbook.m1.typedata.getSelection().equals("MC DATA"))return true;
    String action = scanbook.m1.whatyouwant.getSelectedAction();
    if(action != null && action.equals("RunorCart"))
       return true;
    if(scanbook.m1.selectDataBy.getSelection().equals("YEAR")){
       return true; 
    }else{
	//       System.out.println("********Text : *"+trimmedText+"*"); 
       if(trimmedText.length() == 0 || trimmedText == null){
          errorMessage msg = new errorMessage(
                        scanbook.m1,errMsg);   
          msg.newline("Empty field in Runs/Fills selection");
          msg.newline("Please correct");
          msg.display();
          return false;
       }
    }
    while( (i = localText.indexOf(' ')) > 0){
      String s1 = localText.substring(0,i);
      String s2 = localText.substring(i+1);
      localText = s1+s2;
    }
    if (verifySyntax(localText)){
      try{
        // First the "BETWEEN"case
        localText = trimmedText; 
        if( (i=localText.indexOf('/')) > 0){
          begin = localText.substring(0,i);
          end = localText.substring(i+1);
          finalText = "btw "+prepareRunNb(begin.trim())+" "+
                             prepareRunNb(end.trim());
	  //	    System.out.println("******** Y passe btw**" + localText); 
        }      
        // Now the "OR" case
        localText = trimmedText; 
        if( (i=localText.indexOf(',')) > 0){
          begin = localText.substring(0,i);
          end = localText.substring(i+1);
          finalText = "or  "+prepareRunNb(begin.trim());
          localText = end;
          while( (i=localText.indexOf(',')) > 0){
             begin = localText.substring(0,i);
             end = localText.substring(i+1);
             finalText += " "+prepareRunNb(begin.trim());
             localText = end;
	  }
          finalText += " "+prepareRunNb(end.trim());
        }      
        // And the "ONE RUN" case 
        localText = trimmedText; 
        if( (i=localText.indexOf('/')) == -1 && 
            (i=localText.indexOf(',')) == -1){
          finalText = "btw "+prepareRunNb(localText.trim())+" "+
                             prepareRunNb(localText.trim());
        }      
        verifiedText = finalText;
        return verifyRunsFills(finalText,
               scanbook.m1.selectDataBy.getSelection());
      }catch(Exception e){
        errMsg = e.getMessage();
      }
    }
    errorMessage msg = new errorMessage(
                        scanbook.m1,errMsg);   
        msg.newline("  ");
        msg.newline("Please correct");
        msg.display();
    return false;
  }
  boolean verifyRunsFills(String line,String runOrFill)throws Exception {
    int first, other;
    listRow lr;
    if(line.length() > 0){
      String work = line.substring(4);
      StringTokenizer words = new StringTokenizer(work);
      first = Integer.parseInt(words.nextToken());
      int ny = byYear.size();
      lr = null;
      String msg = " Fill ";
      
      if(!runOrFill.equals("YEAR")){
        if(runOrFill.equals("RUN(s)"))msg = " Run ";
        for(int i = 0;i<ny;i++){
          if(runOrFill.equals("RUN(s)")){
              if( ((listRow)byYear.elementAt(i)).verifyRun(first)){
                lr = (listRow)byYear.elementAt(i);
                break;
	      }
	  }else {
              if( ((listRow)byYear.elementAt(i)).verifyFill(first)){
                lr = (listRow)byYear.elementAt(i);
                break;
              }
	  }
        }
        if(lr == null){
                  throw new Exception("Unknown year for"+msg+
                  String.valueOf(first)+"\n");
        }
      }
      int ty = lr.year;
      //      System.out.println("First year :  "+String.valueOf(ty));
      if(lr != null){
        while(words.hasMoreElements()){
           other  = Integer.parseInt(words.nextToken());
           if(runOrFill.equals("RUN(s)")){
             if(! lr.verifyRun(other)){
                throw new Exception("Runs "+String.valueOf(first)+
                       " and "+String.valueOf(other)+
                       " do not belong to the same year \n");
	     }
	   }else{
               if(! lr.verifyFill(other)){
                  throw new Exception("Fills "+String.valueOf(first)+
                       " and "+String.valueOf(other)+
                       " do not belong to the same year \n");
	       }
	   }
	}
      }
    }
    return true;
  }
  boolean verifySyntax(String instr){
    char chars[] = instr.toCharArray();
    int n = chars.length;
    int nsl = 0;
    int ncomma = 0;
    int nbadc = 0;
    boolean goodchar;
    int i;
    for(i=0; i<n; i++){
      goodchar = false;
      if(chars[i] == '/'){
        nsl++;
        goodchar = true;
      }
      if(chars[i] == ','){
        ncomma++;
        goodchar = true;
      }
      if(Character.isDigit(chars[i])){
        goodchar = true;
      }
      if(!goodchar)nbadc++;
    }
    if(nbadc > 0)return false;
    if(nsl > 1)return false;
    if(nsl > 0 && ncomma >0)return false;
    // Here we decode the case DDDD,DDDD
    // Search for commas separated by at least 1 other character
    int ndig = 0;
    for(i=0; i<n; i++){
      if(chars[i] == ','){
        if(ndig == 0)return false;
        ndig = 0;
      }
      else ndig++;
    } 
    return true;
  }
  String prepareRunNb(String in) throws Exception {
    int inLength = in.length();
    if( inLength > 5) throw new Exception("Too many characters in field :"+
                      "\n\n"+in);
    StringBuffer b = new StringBuffer(in);
    int add = 5 - inLength;
    for(int i=0; i<add;i++){
      b.insert(0,'0');
    }
    return b.toString();
  }
  public String getMenuName(){
    return menuName;
  }
  public void addItem(String lbl){
    addItem(lbl,false,true);
  }
  public void addItem(String lbl, boolean select, boolean enabled){
    runslist.addItem(lbl);
    byYear.addElement(new listRow(lbl));
    if(select){
      runslist.select(runslist.getItemCount()-1);
    }
  }
  public Insets getInsets(){
    return new Insets(10,10,10,10);
  }
  public void removeAll(){
    runslist.removeAll();
  }
  public void itemStateChanged(ItemEvent e) {
        String lbl =  runslist.getItem(((Integer)(e.getItem())).intValue());
        scanbook.callbacks(menuName,lbl);
  }
}

class listRow{

  int year, firstRun, lastRun, firstFill, lastFill;
  String work;

  listRow(String lineIn){
    work = "        "+lineIn.substring(8);
    StringTokenizer words = new StringTokenizer(work);
    year       = Integer.parseInt(words.nextToken());
    firstRun   = Integer.parseInt(words.nextToken());
    lastRun    = Integer.parseInt(words.nextToken());
    firstFill  = Integer.parseInt(words.nextToken());
    lastFill   = Integer.parseInt(words.nextToken());
  }
  boolean  verifyFill(int testFill){
    if(testFill >= firstFill && testFill <= lastFill)return true;
    return false;
  }
  boolean verifyRun(int testRun){
    if(testRun >= firstRun && testRun <= lastRun)return true;
    return false;
  }
}
