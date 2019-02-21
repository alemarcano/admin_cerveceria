#Funciones sin parametros
#Conversor de Bolivares a Dolares
import os

def menu():
    print("1. Dolar")
    print("2. Dolar canadiense")
    print("3. Euro")

    print("Cuanto tienes en bolivares?")
    global bolivares
    bolivares = input ()
    bolivares = float(bolivares)
    print("Que tipo de cambio deseas realizar?")
    global cambio 
    cambio = input()
    cambio = int (cambio)
    #evaluando tipo de cambio
    if(cambio ==1):
        dolares()
    elif(cambio==2):
        dolares_Can()
    elif(cambio==3):
        euros()
    else:
        print("El tipo de cambio que seleccionaste no existe")
    print("Deseas hacer otro tipo de cambio? (Si/No)?")
    global resp
    resp = input()
    resp = resp.lower()
    otraVez()
   
def dolares():
    print("Cual es el precio del dolar actual?")
    global dolarhoy
    dolarhoy = input()
    dolarhoy = float(dolarhoy)
    global dinerito
    dinerito = bolivares/dolarhoy
    print("Tienes ", dinerito, " dolares")

def dolares_Can():
    print("Cual es el precio del dolar canadiense hoy?")
    global dolarChoy
    dolarChoy = input()
    dolarChoy = float(dolarChoy)
    global dinerito
    dinerito = bolivares/dolarChoy
    print("Tienes ", dinerito, " dolares canadienses")


def euros():
    print("Cual es el precio del euro hoy?")
    global euro
    euro = input()
    euro = float(euro)
    global dinerito
    dinerito = bolivares/euro
    print("Tienes ", dinerito, " dolares canadienses")

def otraVez():
    while (resp!="no"):
        os.system('cls')
        menu()

menu()