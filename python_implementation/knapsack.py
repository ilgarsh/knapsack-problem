from pyeasyga import pyeasyga

data = open("../38.txt", 'r')
items = []
for line in data:
    items.append(map(float, line.split()))
maxCarrying = items[0][0]
maxCapacity = items[0][1]
del items[0]    

ga = pyeasyga.GeneticAlgorithm(items)   

def fitness(individual, data):
    price = 0
    global carrying
    global capacity
    carrying = 0
    capacity = 0
    for selected, [currentCarrying, currentCapacity, currentPrice] in zip(individual, data):
        if selected:
            if carrying + currentCarrying > maxCarrying or capacity + currentCapacity > maxCapacity:
                price = 0
                break
            price += currentPrice
            carrying += currentCarrying
            capacity += currentCapacity
    return price

def print_best_individual(data):
    print "Price: " + str(data[0])
    print "Carrying: " + str(carrying)
    print "Capacity: " + str(capacity)
    print "Items: " + str([i for i, x in enumerate(data[1]) if x == 1])


ga.fitness_function = fitness               
ga.run()                                    
print_best_individual(ga.best_individual())