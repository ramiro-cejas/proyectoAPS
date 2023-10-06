const express = require('express');
const app = express();
const port = 3000;

// Configurar Express para servir archivos estáticos desde la carpeta "public"
app.use(express.static('public'));
app.use(express.static('src'));

// Ruta de inicio que responde con el archivo HTMLnp
app.get('/', (req, res) => {
    res.sendFile(__dirname + '/src/html/login.html'); // Cambia la ruta según la ubicación de tu archivo HTML
});

// Iniciar el servidor
app.listen(port, () => {
    console.log(`Servidor web en http://localhost:${port}`);
});
