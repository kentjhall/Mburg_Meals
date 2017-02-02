//: Playground - noun: a place where people can play

import UIKit

func movDownMeals(meals: inout Array<String>, daysFurther: Int) {
    if daysFurther+1 <= 8 {
        meals[0] = meals[daysFurther]
        for i in (daysFurther+1)...8 {
            if meals[i] != "" {
                meals[i-daysFurther] = meals[i]
            }
            else{
                meals[i-daysFurther] = ""
                for n in (i+1)-daysFurther...8 {
                    meals[n] = ""
                }
            }
        }
    }
    else {
        meals[0] = ""
        for i in 1...7 {
            meals[i] = ""
        }
    }
}

var meals = ["Muffin", "Egg", "", "", "", "", "", "", ""]
var daysFurther = 1


movDownMeals(meals: &meals, daysFurther: daysFurther)
