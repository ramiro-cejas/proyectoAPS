function login(){
    var username = document.getElementById("username").value;
    var password = document.getElementById("password").value;
    if(username == "cliente1" && password == "cliente1" || username == "cliente2" && password == "cliente2"){
        window.location.href = "changePassword.html";
    }else if(username == "empleado1" && password == "empleado1" || username == "empleado2" && password == "empleado2"){
        window.location.href = "registrarCliente.html";
    }else if(username == "admin" && password == "admin"){
        window.location.href = "registrarEmpleado.html";
    }else{
        alert("Usuario o contraseña incorrecta");
    }
}