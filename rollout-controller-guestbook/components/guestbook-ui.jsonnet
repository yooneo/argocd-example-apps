local env = std.extVar("__ksonnet/environments");
local params = std.extVar("__ksonnet/params").components["guestbook-ui"];
[
   {
      "apiVersion": "v1",
      "kind": "Service",
      "metadata": {
         "name": params.name + "-preview" 
      },
      "spec": {
         "ports": [
            {
               "port": params.previewServicePort,
               "targetPort": params.containerPort
            }
         ],
         "selector": {
            "app": params.name
         },
         "type": params.type
      }
   },
   {
      "apiVersion": "v1",
      "kind": "Service",
      "metadata": {
         "name": params.name + "-active" 
      },
      "spec": {
         "ports": [
            {
               "port": params.activeServicePort,
               "targetPort": params.containerPort
            }
         ],
         "selector": {
            "app": params.name
         },
         "type": params.type
      }
   },
   {
      "apiVersion": "argoproj.io/v1alpha1",
      "kind": "Rollout",
      "metadata": {
         "name": params.name
      },
      "spec": {
         "replicas": params.replicas,
         "selector": {
            "matchLabels": {
               "app": params.name
            },
         },
         "template": {
            "metadata": {
               "labels": {
                  "app": params.name
               }
            },
            "spec": {
               "containers": [
                  {
                     "image": params.image,
                     "name": params.name,
                     "ports": [
                     {
                        "containerPort": params.containerPort
                     }
                     ]
                  }
               ]
            }
         },
         "minReadySeconds": 30,
         "strategy": {
            "type": "BlueGreenUpdate",
            "blueGreen": {
               "activeService": params.name + "-active",
               "previewService": params.name + "-preview",
            },
         },
      },
   }
]
