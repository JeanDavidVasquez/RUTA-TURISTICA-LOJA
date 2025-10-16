# 🌐 **RUTA-TURISTICA-LOJA**

> *Innovando el futuro, un código a la vez.*

---

## **Integrantes del Equipo**

<table>
  <tr>
    <td align="center">
      <img src="https://github.com/user-attachments/assets/dba58d44-a031-47bd-a45f-68a8ef8d9dfb" width="170" alt="Foto de Iam Estrella">
      <br>
      <strong>Iam Estrella</strong>
      <br>
      <em>Backend Developer</em>
    </td>
    <td align="center">
      <img src="https://github.com/user-attachments/assets/15c96ff8-cb25-406e-9666-57cd3c0c58fa" width="150" alt="Foto de Jean Vásquez">
      <br>
      <strong>Jean Vásquez</strong>
      <br>
      <em>Diseñador UX/UI</em>
    </td>
    <td align="center">
      <img src="https://github.com/user-attachments/assets/270828c4-40a5-4b45-849d-018b9dfcff27" width="180" alt="Foto de Santiago Riofrío">
      <br>
      <strong>Raul Medina</strong>
      <br>
      <em>Backend Developer</em>
    </td>
  </tr>
</table>

---

## 🎯 **Objetivo del Proyecto**

Desarrollar un **sistema móvil** para el registro, categorización y exploración de lugares turísticos, con la capacidad de generar **rutas personalizadas**, funcionar en **modo offline** y mantener una **comunicación escalable con una API** (basada en Django).

---

## ⚙️ **Requisitos Funcionales**

### **1. Registro y Autenticación de Usuarios**
- **RF-1.1:** El sistema debe permitir a los usuarios registrarse creando una cuenta con correo electrónico y contraseña.  
- **RF-1.2:** El sistema debe permitir a los usuarios iniciar sesión utilizando sus credenciales (correo electrónico y contraseña).  
- **RF-1.3:** El sistema debe permitir a los usuarios cerrar sesión de forma segura.  
- **RF-1.4:** El sistema debe permitir a los usuarios restablecer su contraseña en caso de olvido (ej., mediante correo electrónico).  
- **RF-1.5:** El sistema debe permitir a los usuarios ver y editar su perfil (nombre, correo electrónico, contraseña).  

---

### **2. Exploración de Lugares Turísticos**
- **RF-2.1:** El sistema debe permitir a los usuarios ver un listado de lugares turísticos obtenidos de la API.  
- **RF-2.2:** El sistema debe permitir a los usuarios filtrar la lista de lugares turísticos por categoría (obtenidas desde la API).  
- **RF-2.3:** El sistema debe permitir a los usuarios buscar lugares turísticos por nombre o palabras clave.  
- **RF-2.4:** El sistema debe permitir a los usuarios ver los detalles completos de un lugar turístico (nombre, descripción, fotos, dirección, horarios, categoría, contacto, servicios).  

---

### **3. Gestión de Rutas Turísticas**
- **RF-3.1:** El sistema debe permitir a los usuarios seleccionar lugares turísticos para crear una ruta personalizada.  
- **RF-3.2:** El sistema debe permitir al usuario seleccionar el orden de los lugares o dejar que el sistema optimice la ruta.  
- **RF-3.3:** El sistema debe generar rutas optimizadas considerando distancia y tiempo estimado.  
- **RF-3.4:** El sistema debe mostrar la ruta en un mapa interactivo.  
- **RF-3.5:** El sistema debe mostrar indicaciones paso a paso y tiempo estimado de llegada.  
- **RF-3.6:** El sistema debe permitir guardar las rutas creadas.  
- **RF-3.7:** El sistema debe permitir ver una lista de rutas guardadas.  
- **RF-3.8:** El sistema debe permitir editar las rutas guardadas.  
- **RF-3.9:** El sistema debe permitir eliminar rutas guardadas.  
- **RF-3.10:** El sistema debe ofrecer sugerencias de rutas predefinidas (ej., “Ruta gastronómica”, “Ruta histórica”).  

---

### **4. Listas de Lugares y Favoritos**
- **RF-4.1:** El sistema debe permitir agregar lugares turísticos a una lista de “Pendientes”.  
- **RF-4.2:** El sistema debe permitir marcar lugares como “Visitados”.  
- **RF-4.3:** El sistema debe mostrar listas separadas de “Pendientes” y “Visitados”.  
- **RF-4.4:** El sistema debe permitir agregar lugares a una lista de “Favoritos”.  
- **RF-4.5:** El sistema debe permitir ver la lista de lugares “Favoritos”.  

---

### **5. Mapas y Geolocalización**
- **RF-5.1:** El sistema debe mostrar los lugares turísticos en un mapa.  
- **RF-5.2:** Los marcadores en el mapa deben ser claros e informativos.  
- **RF-5.3:** El sistema debe permitir al usuario ver su ubicación actual.  
- **RF-5.4:** El sistema debe permitir obtener indicaciones hacia un destino.  
- **RF-5.5:** El sistema debe integrarse con sistemas externos de navegación.  
- **RF-5.6:** El sistema debe mostrar lugares turísticos cercanos a la ubicación del usuario.  

---

### **6. Modo Offline**
- **RF-6.1:** El sistema debe permitir consultar información básica de los lugares turísticos sin conexión.  
- **RF-6.2:** El sistema debe permitir acceder a las rutas guardadas sin conexión.  
- **RF-6.3:** El sistema debe sincronizar automáticamente los datos al recuperar conexión.  
- **RF-6.4:** El sistema debe indicar al usuario cuándo está en modo offline y cuándo sincroniza datos.  
- **RF-6.5:** El sistema debe manejar conflictos durante la sincronización de datos.  

---

### **7. Integración con API (Django)**
- **RF-7.1:** El sistema debe comunicarse con una API para gestionar información de lugares, categorías, rutas y preferencias del usuario.  
- **RF-7.2:** La aplicación debe utilizar endpoints específicos de la API para:  
  - Obtener listado de lugares turísticos (con paginación y filtrado).  
  - Obtener detalles de un lugar turístico.  
  - Obtener listado de categorías.  
  - Guardar y obtener rutas turísticas.  
  - Obtener listado de rutas guardadas por usuario.  
  - Guardar y obtener listas de pendientes, visitados y favoritos.  
  - Gestionar registro, inicio de sesión y perfiles de usuario.  
- **RF-7.3:** La aplicación debe manejar errores de la API mostrando mensajes de error amigables al usuario.
  
---
