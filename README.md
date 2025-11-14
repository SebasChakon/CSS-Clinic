# Servicios Médicos CSS - Grupo 60

**URL de la aplicación en Render:** https://rendeerr.onrender.com/

## Descripción del Proyecto
Sistema web completo para gestión de reservas médicas que conecta pacientes con doctores, permitiendo agendar, gestionar y realizar seguimiento de citas médicas.

## Funcionalidades Implementadas

### Autenticación y Usuarios
- **Sistema de registro y login** con Devise
- **Roles de usuario**: Paciente y Doctor
- **Panel de administración** para gestión de usuarios

### Gestión Completa de Reservas
- **Crear nuevas reservas**
- **Ver listado de reservas con filtros por estado**
- **Editar y actualizar reservas existentes**
- **Sistema de estados**: Pendiente → Confirmada → Completada/Cancelada
- **Acciones específicas**:
  - Cancelar reserva
  - Confirmar reserva (doctores)
  - Completar reserva (doctores)

### API de Farmacias Cercanas
- **Búsqueda de farmacias** por geolocalización
- **Integración API externa**
- **Interfaz responsive** actualizaciones en tiempo real

### Sistema de Mensajería en Tiempo Real
- **Chat integrado** entre paciente y doctor
- **Creación de mensajes** en cada reserva
- **Historial de conversaciones**

### Sistema de Reseñas
- **Crear reseñas** para reservas completadas
- **Editar y actualizar reseñas existentes**
- **Eliminar reseñas propias**

### Gestión de Horarios Médicos
- **Crear horarios**
- **Gestionar disponibilidad propia**
- **Editar y eliminar horarios existentes**

### Panel de Administración
- **Panel de gestión**
- **Convertir usuarios a doctores**
- **Gestión de doctores**
- **Administración de reservas**

# Pasos de Instalación

### Clonar el repositorio
git clone https://github.com/IIC2143/2025-2-grupo-60.git

### Moverse a la carpeta
cd 2025-2-grupo-60

### Instalar dependencias de Ruby
bundle install

### Instalar dependencias de JavaScript
yarn install

### Configurar base de datos
rails db:create

rails db:migrate

rails db:seed

### Ejecutar el servidor
rails server

### Datos para ingresar y hacer testing:

Medico: "Email: doctor@clinica.com
        Contraseña: 123456"

Paciente: "Email: paciente@clinica.com
        Contraseña: 123456"

Administrador: "Email: admin@clinica.com
                Contraseña: 123456"