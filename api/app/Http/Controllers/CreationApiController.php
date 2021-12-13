<?php

namespace App\Http\Controllers;

use App\Models\Creation;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

class CreationApiController extends Controller
{
    function list($page = 1): JsonResponse
    {
        $creations = Creation::orderBy('created_at', 'desc')->paginate(10, ['*'], 'page', $page);

        // format dates and remove hidden fields
        foreach ($creations as $creation) {
            /** @var Creation $creation */

            $creation->description = "";

            $creation->created = $creation->created_at->ago();
            $creation->updated = $creation->updated_at->ago();

            $creation->poster = "Anonymous";

            unset($creation->created_at);
            unset($creation->updated_at);
        }

        return response()->json($creations);
    }

    function create(Request $request): JsonResponse
    {
        $json = json_decode($request->getContent(), true);

        // check if the request is valid
        if (!isset($json['title']) || !isset($json['json_data'])) {
            return response()->json(['result' => 1, 'msg' => 'Invalid request'], 400);
        }

        $creation = new Creation();

        $creation->title = $json['title'];
        $creation->json_data = json_encode($json['json_data']);

        $creation->save();

        return response()->json(["result" => 0, 'object' => $creation]);
    }

}
