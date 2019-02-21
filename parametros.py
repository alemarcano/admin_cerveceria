resp = "si"
aciertos=0
errores=0
def sumar(n1,n2):
    print("Cuanto suman ", n1, " + ", n2, "? ")
    global resulUsuario
    resulUsuario = input()
    resulUsuario = float(resulUsuario)
    global resulReal
    resulReal = n1+n2
    if(resulReal==resulUsuario):
        print("Resultado Correcto")
        global aciertos
        aciertos = aciertos + 1
    else:
        print("Resultado incorrecto")
        global errores
        errores = errores + 1
while(resp!="no"):
    print("Ingrrese un numero:")
    global num1
    num1 = input()
    num1 = float(num1)
    print("Ingrrese otro numero:")
    global num2
    num2 = input()
    num2 = float(num2)
    sumar(num1, num2)
    print("Deseas seguir participando")
    global resp
    resp = input()
    resp= resp.lower()

    