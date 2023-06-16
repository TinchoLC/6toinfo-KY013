#include <math.h>

int flag = 1;//Actua como bandera para que una vez por segundo se ejecute el loop
int readVal; //Almacenará un valor de 0 a 1023, representando como int el nivel de voltaje
double temp; //Almacenará el valor de temperatura final

int sensorPin = A0; // Entrada
double cA = 0.001129148; // Coeficience A
double cB = 0.000234125; // Coeficience B
double cC = 0.0000000876741; // Coeficience C


void ADC_init()
{
  ADMUX = (1 << REFS0); //default Ch-0; VrefAnálogo = 5V
  ADCSRA |= (1 << ADEN) | (0 << ADSC) | (0 << ADATE); //ADATE en 0 = auto-trigger OFF// //ADSC en 0 = Conversión no iniciada// //ADEN en 1 = ADC encendido//
  ADCSRB = 0x00; //Todo en 0 el registro ADCSRB porque no nos es de utilidad
}

//Esta función logra reemplazar a analogRead() para leer el valor analógico//
int aRead(uint8_t pin)
{
  //Empieza la conversion
  // Escribiendo un 1 en ADSC
  ADCSRA |= (1 << ADSC);

 //Loopea hasta que ADSC sea 0 
  while (ADCSRA & (1 << ADSC)); 
  //Los primeros 8 bits se encuentran en ADCL, los otros 2 en ADCH, entonces se aplica un OR entre ADCL y (ADC)
  ADC = (ADCL | (ADCH << 8));
  return (ADC);
}


// Esta funcion recibira la entrada (Potencia) y devolvera la temperatura
double SteinHH(int RawADC) {
    double Temp;
    double logRes;
    
    logRes = log(10000.0*((1024.0/RawADC-1))); // Calculo del logaritmo de la resistencia del termistor (Tambien pasa de Potencia a Resistencia)
    
    // 1/T = (A + B * log R + C * (log R)^3) -- Ecuacion Steinhart Hart
    Temp = 1 / (cA + cB * logRes + cC * logRes * logRes * logRes); // Aplicar ecuacion Steinhart Hart
    
    // Como la ecuacion obtiene grados Kelvin, debemos cambiarlos a grados Centigrados:
    Temp = Temp - 273.15;            // Convertir Kelvin a grados Centigrados
    
    return Temp; // Retornamos la temperatura final
}



void setup() {

    //Configuración del TIMER 
    TCCR1A = 0;//seteo todos los bits del registro de control del timer en 0
    TCCR1B = 0;//seteo todos los bits del registro de control del timer en 0
    TCNT1 = 0;//inicializo el registro del contador en 0
    OCR1A = 0x3D08;// Valor del registro de comparación para que la frecuencia de interrupción sea 1hz
    TCCR1B |= (1 << WGM12)| (1 << CS10) | (1 << CS12);//establezco mediante (1<<WGM12) al modo CTC como metodo de interrupción y con (1<<CS10) (1<<CS12) establezco el preescaler en 1024
    TIMSK1 |= (1<< OCIE1A);//Habilito la interrupción con OCR1A como registro de comparación
  
    Serial.begin(9600); // Para poder utilizar Serial
  	ADC_init();
}

void loop() {
  if (flag){//Si pasó 1 segundo, se actualizan las medidas//
    readVal= aRead(sensorPin); // La potencia obtenida del sensor del Pin // Cambiar analogRead
    temp = SteinHH(readVal); // Utiliza la funcion para obtener la temperatura
    
    // Serial.println(readVal); // Se muestra la potencia
    Serial.println(temp);  // Se muestra la temperatura
    flag = false;//Como ya se hizo una vez dentro de un segundo, se pasa el valor a 0
  }
}
ISR(TIMER1_COMPA_vect){ // codigo de interrupción, se ejecuta al pasar 1 segundo completo
	flag = true;//pasó un segundo, se activa la flag otra vez
}
