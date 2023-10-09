const express = require('express');
const app = express();
const port = 3000;

// Configurar Express para servir archivos estáticos desde la carpeta "public"
app.use(express.static('public'));
app.use(express.static('src'));
app.use(express.static('src/css'));
app.use(express.static('src/js'));

// Ruta de inicio que responde con el archivo HTMLnp
app.get('/', (req, res) => {
    res.sendFile(__dirname + '/src/login.html'); // Cambia la ruta según la ubicación de tu archivo HTML
});

app.get('/css/login.css', (req, res) => {
    res.sendFile(__dirname + '/src/login.css'); // Cambia la ruta según la ubicación de tu archivo css
  })

// Iniciar el servidor
app.listen(port, () => {
    console.log(`Servidor web en http://localhost:${port}`);
});

module.export = app;