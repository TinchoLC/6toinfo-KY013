#include <math.h>

int sensorPin = A0; // Entrada
double cA = 0.001129148 // Coeficience A
double cB = 0.000234125 // Coeficience B
double cC = 0.0000000876741 // Coeficience C

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
    int readVal= analogRead(sensorPin); // La potencia obtenida del sensor del Pin
    double temp = SteinHH(readVal); // Utiliza la funcion para obtener la temperatura
    
    // Serial.println(readVal); // Se muestra la potencia
    Serial.println(temp);  // Se muestra la temperatura
 
    delay(500); // CAMBIAR ESTE DELAY POR ALGO COBISTICO
}
