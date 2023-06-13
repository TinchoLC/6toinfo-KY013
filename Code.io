#include <math.h>
#define sbi(sfr, bit) (_SFR_BYTE(sfr) |= _BV(bit))

uint8_t analog_reference = DEFAULT;


int sensorPin = A0; // Entrada
double cA = 0.001129148; // Coeficience A
double cB = 0.000234125; // Coeficience B
double cC = 0.0000000876741; // Coeficience C


//Esta función logra reemplazar a analogRead() para leer el valor analógico//
int aRead(uint8_t pin){
   if (pin >= 14) pin -= 14; // allow for channel or pin numbers
   // set the analog reference (high two bits of ADMUX) and select the
   // channel (low 4 bits).  this also sets ADLAR (left-adjust result)
   // to 0 (the default).


   ADMUX = (analog_reference << 6) | (pin & 0x07);
   // without a delay, we seem to read from the wrong channel

   //delay(1);

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
    Serial.begin(9600); // Para poder utilizar Serial
}

void loop() {
    int readVal= aRead(sensorPin); // La potencia obtenida del sensor del Pin // Cambiar analogRead
    double temp = SteinHH(readVal); // Utiliza la funcion para obtener la temperatura
    
    // Serial.println(readVal); // Se muestra la potencia
    Serial.println(temp);  // Se muestra la temperatura
 
    delay(2000); // Hacer con interrupciones o fuerza bruta (creo que con un timer va a ser mejor).
}
