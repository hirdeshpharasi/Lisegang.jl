#####################           TEST            ################################
#This program is a test code for the Liesegang package, it is a simple model based
#on the Stochastic Rotation Dynamics model.
#Here the idea is to have two species of particles, A and B
#loading the package Liesegang.jl
using Liesegang
using Plots #plotting package
################################################################################
#defining the parameters
Lx = 1000; Ly = 10 #size of the space
dim = [Lx,Ly]
a = 1.0 #size of the boxes, default = 1
m = [1.0, 2.0] #masses
np = [25000,25000] #number of particles
Tr = 1/3 #reference temperature
τ = 1.73 #1.73
tmax = 1000
angles = [90.0, 90.0]
################################################################################
###########                       INITIALIZING                       ###########

parts = vcat([particle(1,dim, m[1],1) for _ in 1:np[1]], [particle(Lx,dim,m[1],2) for _ in 1:np[2]]) #initializing the particles.
#normalizing the momentum
norm_momentum!(parts)
#now the temperature to the reference Tr
norm_temperature!(parts, Tr)
#initializing the boxes
boxes = [box(m) for _ in 1:(Lx * Ly)]

################################################################################
#########################    now the simulation...   ###########################

anim = @animate for t in 1:tmax
    #streaming step
    getpos_slip!(parts, τ, dim)
    #first the grid is shifted
    shift_grid!(parts, a, dim)
    #now label the particles in the boxes
    get_box(parts, boxes, Lx)
    #the momentums and rotations are computed for every specie
    box_vel(parts,boxes)
    parts_vels!(parts, boxes, angles)
    #now the same especies
    box_velmc(parts,boxes,m)
    parts_vels!(parts,boxes,angles)
    #getpos_pbc!(parts, τ, dim)
    #shifting back the particles to their original places
    shiftback_grid!(parts)
    x = [parts[i].pos[1] for i in 1:np[1]]
    y = [parts[i].pos[2] for i in 1:np[1]]
    x1 = [parts[i].pos[1] for i in (np[1]+1):(np[2]+np[1])]
    y1 = [parts[i].pos[2] for i in (np[1]+1):(np[2]+np[1])]
    #vx = [parts[i].vel[1]/3 for i in 1:np] #dividing the vectors by a factor of 3 just for the visualization.
    #vy = [parts[i].vel[2]/3 for i in 1:np]
    scatter(x,y, xlims = (0,Lx), ylims = (0,Ly), size = (Lx,Ly*10))
    scatter!(x1,y1)# xlims = (0,Lx), ylims = (0,Ly))
    #quiver(x, y, quiver = (vx, vy), xlims =(0,Lx), ylims = (0,Ly))
end

gif(anim, "testmulti-prueba.gif", fps = 8)
