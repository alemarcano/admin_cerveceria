import tkinter as tk #Biblioteca para ventanas





def main(): 
    def suma():
        suma= int(entrada1.get())+ int(entrada2.get())
        return var.set(suma)
    def cerrar():
        ventana.destroy()

 

    def abrirventana2():
       # ventana.withdraw() #cierra la ventana principal
        win=tk.Toplevel() #ventana hija
        win.geometry('500x700+750+0') #Ancho y Alto
        win.configure(background='dark turquoise')
        e = tk.Label(win, text ="Bienvenidos", bg = "pink", fg = "white")
        e.pack(padx=5, pady=5, ipadx=5, ipady=5, fill=tk.X) #extender tk.X


        botonc2= tk.Button(win, text="Cerrar", fg = "green", command=win.destroy)
        botonc2.pack(side=tk.TOP)





    ventana=tk.Tk()
    ventana.title("Primera Ventana")
    ventana.geometry('500x700') #Ancho y Alto
    ventana.configure(background='midnight blue')
    var=tk.StringVar()
    image = tk.PhotoImage(file="regional.png")
    image = image.subsample(4,4)
    label = tk.Label(image=image)
    label.pack()

    etiqueta1 = tk.Label(ventana, text ="Nombre", bg = "pink", fg = "white")
    etiqueta1.pack(padx=5, pady=5, ipadx=5, ipady=5, fill=tk.X) #extender tk.X
    entrada1 = tk.Entry(ventana)
    entrada1.pack(fill=tk.X,padx=5, pady=5, ipadx=5, ipady=5 )

    etiqueta2 = tk.Label(ventana, text ="Apellido", bg = "pink", fg = "white")
    etiqueta2.pack(padx=5, pady=5, ipadx=5, ipady=5, fill=tk.X) #extender tk.X
    entrada2 = tk.Entry(ventana)
    entrada2.pack(fill=tk.X,padx=5, pady=5, ipadx=5, ipady=5 )

    botonsuma = tk.Button(ventana, text="Suma", fg = "pink", command=suma)
    botonsuma.pack(side=tk.TOP)

    botonventana = tk.Button(ventana, text="Abrir ventana", fg = "green", command=abrirventana2)
    botonventana.pack(side=tk.TOP)

    res = tk.Label(ventana, text ="Produccion", bg = "plum", fg = "white", textvariable= var)
    res.pack(padx=5, pady=5)

    botoncierra = tk.Button(ventana, text="Cerrar", fg = "pink", command=cerrar)
    botoncierra.pack(side=tk.TOP)


    ventana.mainloop()

#main corro la pantalla
if __name__ == '__main__':
    main()