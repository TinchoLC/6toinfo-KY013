# 6toinfo-KY013

Proyecto que estamos haciendo para la materia Instalación y Reemplazo de Componentes Internos 2023 de 6to año del Instituto Politecnico Superior Gral. San Martín.

La primera parte del proyecto consiste en poder leer los datos de un sensor analógico sin utilizar bibliotecas externas (ni la función AnalogRead o Delay), se está llevando a cabo con el sensor NTC KY013.

## Problemas que debemos llevar a cabo en la primera parte del proyecto
- Linealización de la curva NTC con la ecuación Steinhart Hart ☑
- Reemplazar AnalogRead ☑
- Reemplazar Delay con interrupciones ☑

En un principio podemos utilizar Serial para mostrar los datos (ya que luego cambiaremos esto), pero en un futuro debemos enviar los datos a un servidor, lo cual es la segunda parte del proyecto.
