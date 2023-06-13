#include <math.h>
#define sbi(sfr, bit) (_SFR_BYTE(sfr) |= _BV(bit))

uint8_t analog_reference = DEFAULT; //

int flag = 1;//Actua como bandera para que una vez por segundo se ejecute el loop
int readVal; //Almacenará un valor de 0 a 1023, representando como int el nivel de voltaje
double temp; //Almacenará el valor de temperatura final

int sensorPin = A0; // Entrada
double cA = 0.001129148; // Coeficience A
double cB = 0.000234125; // Coeficience B
double cC = 0.0000000876741; // Coeficience C


//Esta función logra reemplazar a analogRead() para leer el valor analógico//
int aRead(uint8_t pin)

{
   if (pin >= 14) pin -= 14; // allow for channel or pin numbers
  
   // set the analog reference (high two bits of ADMUX) and select the
   // channel (low 4 bits).  this also sets ADLAR (left-adjust result)
   // to 0 (the default).
   ADMUX = (analog_reference << 6) | (pin & 0x07);
   // without a delay, we seem to read from the wrong channel

   delay(1);

   // start the conversion
   sbi(ADCSRA, ADSC);
   // ADSC is cleared when the conversion finishes
   while (bit_is_set(ADCSRA, ADSC));
   // ADC macro takes care of reading ADC register.
   // avr-gcc implements the proper reading order: ADCL is read first.
   return ADC;
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
