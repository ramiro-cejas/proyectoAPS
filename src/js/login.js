function login(){
    var username = document.getElementById("username").value;
    var password = document.getElementById("password").value;
    if(username == "cliente1" && password == "cliente1" || username == "cliente2" && password == "cliente2"){
        //window.location.href = "changePassword.html"; // @TODO descomentar
        window.location.href = "recepcion_clientes.html";
    }else if(username == "empleado1" && password == "empleado1" || username == "empleado2" && password == "empleado2"){
        window.location.href = "recepcion_empleado.html";
    }else if(username == "admin" && password == "admin"){
        window.location.href = "recepcion_admin.html";
    }else{
        alert("Usuario o contraseña incorrecta");
    }
}