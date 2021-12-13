<?php

namespace Database\Factories;

use Illuminate\Database\Eloquent\Factories\Factory;

class CreationFactory extends Factory
{
    /**
     * Define the model's default state.
     *
     * @return array
     */
    public function definition()
    {
        $jsonData = "[";
        for($i = 0; $i < 10; $i++) {
            $jsonData .= "[";
            // for random amount
            for($j = 0; $j < 7; $j++) {
                $jsonData .= rand(0, 4);
                if($j < 6) {
                    $jsonData .= ",";
                }
            }

            if($i < 9) {
                $jsonData .= "],";
            } else {
                $jsonData .= "]";
            }
        }
        $jsonData .= "]";

        return [
            'title' => $this->faker->sentence,
            'json_data' => $jsonData,
        ];
    }
}
