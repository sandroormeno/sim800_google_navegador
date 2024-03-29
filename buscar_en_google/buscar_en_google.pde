import processing.serial.*; //<>//
Serial myPort;  
PrintWriter output;
PrintWriter salida;
char data[]= {};
char inByte;
long maxResponseTime_T;
long maxTime = 40000;
String responseString;
long beltTime;
long contador = 0;
String[] lines;
int index = 0;

String buscar = "sandro+ormeño";
  

void setup() 
{
  size(200, 200);
  printArray(Serial.list());
  String portName = Serial.list()[0];
  output = createWriter("tem.txt");
  salida = createWriter("buscar.html");
  myPort = new Serial(this, portName, 9600);
  myPort.write("AT\n");
  waitUntilResponse("OK", 1000);

  myPort.write("AT+HTTPPARA=\"URL\",\"http://www.google.com/search?q=");

  // En esta parte indicar la búsqueda:
  
  myPort.write(buscar);

  //myPort.write("&source=lnms&start=0&sa=N\"\n");
  myPort.write("\"\n");
  waitUntilResponse("OK", 1000);

  myPort.write("AT+HTTPACTION=0\n");
  waitUntilResponse("OK", 8000);

  String[] BYTES = split(responseString, ',');
  double u = Double.valueOf(BYTES[2]).doubleValue();
  println("Total de bytes bajados (double): " + u);
  for (int uu = 0; uu < u/16; uu++) {
    if (uu % 200 == 0) {
      print("|");
    }    
  }
  println("-->fin");
  myPort.write("AT+HTTPREAD\n");
  lee_html();
  println("Listo, ya terminé!");
  output.flush(); 
  output.close(); 
  lines = loadStrings("tem.txt");
  for (int i = 2; i < (lines.length-1); i++) {
    salida.print(lines[i]);    
  }
  salida.flush();
  salida.close();
  // aquí se debe indicar el archivo para abrir en el buscador
  link("file:///C:/Users/Usuario/Desktop/desktop-07-17-2019/html/buscar_en_google/buscar.html");
  exit(); 
}

void lee_html() {
  contador = 0; 
  responseString = "";
  String totalResponse = "";
  while (responseString.indexOf("OK\r") < 0 ) {
    leerData();
    totalResponse = totalResponse + responseString;
    if (contador % 200 == 0) {
      print("|");
    } 
    output.print(responseString);
  } 
  println(" Contador = " + contador);
  myPort.clear();
  responseString = "";
}

void waitUntilResponse(String response, long maxResponseTime)
{
  maxResponseTime_T = maxResponseTime;
  beltTime = millis();
  responseString = "";
  String totalResponse = "";
  while (responseString.indexOf(response) < 0 && millis() - beltTime < maxResponseTime)
  {
    readResponse();
    totalResponse = totalResponse + responseString;
    println(responseString);
  }
  if (totalResponse.length() <= 0)
  {
    println("No response from the module. Check wiring, SIM-card and power!");
    delay(30000);
    exit(); 
  } else if (responseString.indexOf(response) < 0)
  {
    println("Unexpected response from the module");
    println(totalResponse);
    delay(30000);
    exit(); 
  }
}

void readResponse()
{
  responseString = "";
  while (responseString.length() <= 0 || responseString.substring(responseString.length()-2, responseString.length()) != "\n")
  {
    tryToRead();
    if (millis() - beltTime > maxResponseTime_T) {
      return;
    }
  }
}
void leerData() {
  responseString = "";
  while (responseString.length() <= 0 ) {
    tryToRead();
  }
}
void tryToRead()
{
  while (myPort.available()>0)
  {
    char c = myPort.readChar();  
    responseString += c; 
    contador ++;
  }
}