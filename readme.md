
## Usar el SIM800L para buscar en google y ver html en el navegador.

Siempre es bueno estar conectado al internet inalámbricamente.  Wifi es una solución popular, pero tiene mucho más alcance   las redes de telefonía celular. Y un dispositivo GSM como el __SIM800L__, nos permite tener internet en cualquier parte que tenga acceso a una red 2G. Pero no es de nuestra experiencia poder hacerlo fácilmente. En esta demostración se muestra el proceso. 

Con el Sim800L podemos hacer una petición ``GET`` y nos devolverá el código ``HTML`` que podemos abrir en nuestro navegador preferido. Esto se puede hacer desde cualquier aplicativo que tenga acceso al puerto __SERIAL__ y que tenga la posibilidad de codificar líneas de instrucciones en comandos `AT`. 

Podemos usar Arduino.  Pero no tiene la posibilidad de abrir el navegador al terminar el proceso. Podemos usar Python, guardar toda la información en un archivo HTML; pero debemos instalarlo  y bajar alguna librería. Lo más fácil es usar processing, que afortunadamente no se instala. Pero invito a implementar este código en Arduino o Python.

Lo primero es asegurarnos que tenemos Processing en nuestro sistema. <https://Processing.org>.

Luego débenos alimentar el módulo sim800L con 4V, por el medio de una batería lipo (1000mA) o una Li-ion de la misma capacidad, pero mi preferido es una fuente de más de 2A y un __StepDown LM2596__, que es lo que recomienda el fabricante. En  caso de usar baterías , se recomienda un capacitor de 1500uf en paralelo, para evitar que se reinicie cuando requiera  mucho consumo de corriente, que puede llegar a picos de 1A.  Luego requerimos  un dispositivo __FTDI__, de los que hay muchos en el mercado, para comunicarnos con la PC. La conexión es cruzada. Solo necesitamos los canales TX-RX, así que cualquiera que permita hacerlo estará bien. No se requiere el canal de RESET. Luego debemos conectar las tierras, que serán comunes entre el SIM800L, la batería y el FTDI. No se alimentará el módulo GSM con el FTDI, la corriente que puede suministrar la PC es insuficiente, para ello usaremos la baterías o mejor una fuente y el dispositivo StepDown.

<img src='https://raw.githubusercontent.com/sandroormeno/sim800_google_navegador/master/circuito.png' width=600>
<img src='https://raw.githubusercontent.com/sandroormeno/sim800_google_navegador/master/lipo.jpg' width=600>
<img src='https://raw.githubusercontent.com/sandroormeno/sim800_google_navegador/master/lion.jpg' width=600>
<img src='https://raw.githubusercontent.com/sandroormeno/sim800_google_navegador/master/lm2596.jpg' width=600>

El proceso de conexión tiene las siguientes etapas:

La primera etapa la desarrollaremos en forma manual, pero se puede automatizar. La idea es poder continuar haciendo otras búsquedas sin tener iniciar todo el proceso nuevamente. 

1.Para el establecimiento de una conexión con la red celular 2G. Simplemente hay que alimentar el módulo GSM (Sim800L). El módulo nos indicará que ya está listo para ser usado cuando nos envíe el siguiente mensaje,  considerando que debemos iniciar la comunicación con un ``AT``, luego de alimentarlo con 4v:
        
>``AT``   
>``OK``   
>``Call Ready``   
>``SMS Ready``    
        
Esto puede tardar unos 30 segundo o más y no depende de nuestro módulo, sino más bien de la red celular.

2.Luego hay que configurar nuestro servicio de internet. Después de esta instrucción, el módulo cambiará el estado del LED rápidamente. 

>``AT+SAPBR=3,1,"APN","CMNET"``  
>``OK``  
>``AT+SAPBR=1,1``  
>``OK``  
      
El módulo nos devolverá el IP asignado.

>``AT+SAPBR=2,1``  
>``+SAPBR: 1,1,"10.76.40.44"``  
>``OK``  

3.En esta etapa debemos configurar nuestra petición al servidor: 

>``AT+HTTPINIT``  
>``OK``  
>``AT+HTTPPARA="CID",1``  
>``OK``  

Luego de esto estará listo para comunicarnos con el servidor, en este caso con Google. Aquí comienza el proceso automatizado (buscar_en_google.pde).

4.Para esta etapa enviaremos unos parámetros que nos permitirán hacer alguna búsqueda en google. 

>``AT+HTTPPARA="URL","http://www.google.com"``

Luego vamos a pedir que nos devuelva la cantidad de datos:

>``AT+HTTPACTION=0``  
>``OK``  
>``+HTTPACTION: 0,200,61044``  


Dónde 61044 es la cantidad de bytes recibidos. Finalmente  leemos  los datos:

>``AT+HTTPREAD``  
>``+HTTPREAD: 61044``  
>``<!doctype html><html``  
>``OK``  

Nos devuelve todos los datos planos que debemos procesarlos.  Básicamente tenemos que quitarle la primera y la última línea. Luego guardamos los datos en un archivo html.  
5.Para finalizar usaremos estas dos líneas que cierran el servicio y la comunicación con nuestro proveedor de internet.    

>``AT+HTTPTERM``  
>``OK``  
>``AT+SAPBR=0,1``  
>``OK``  


Aquí  algunas indicaciones del código en Processing:

1.En la línea 13 está la variable para ingresar información a  buscar, concatenado con el signo mas(+).

2.En la línea 35 se indica en la variable  `start=0`, el inicio de las coincidencia a publicar. Por ejemplo cero indica que se publicará desde la primera coincidencia. `start=10` indica que se inicia desde la coincidencia 10.

3.En la línea 62 se indica el archivo que se abrirá en el navegador, la ruta debe ser absoluta.  Estoy seguro que se debe personalizar esta línea de código.

