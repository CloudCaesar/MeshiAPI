/**
 * @description Apex controller for Meshy Text-to-3D and Image-to-3D API integration.
 * Handles REST callouts for Meshy API.
 */
public with sharing class MeshyTextTo3DController {
    private static final String ENDPOINT_BASE = 'callout:Meshy_API/openapi/v2/text-to-3d';
    private static final String BALANCE_ENDPOINT = 'callout:Meshy_API/openapi/v2/balance';
    private static final String IMAGE_TO_3D_ENDPOINT = 'callout:Meshy_API/openapi/v2/image-to-3d';

    public class PreviewResponse {
        @AuraEnabled public String taskId;
        @AuraEnabled public String error;
    }

    public class StatusResponse {
        @AuraEnabled public String taskId;
        @AuraEnabled public String status;
        @AuraEnabled public Map<String, String> modelUrls;
        @AuraEnabled public String error;
    }

    /**
     * @description Creates a preview task for Text-to-3D.
     */
    @AuraEnabled
    public static PreviewResponse createPreviewTask(String prompt, String negativePrompt, String artStyle, Boolean shouldRemesh) {
        PreviewResponse response = new PreviewResponse();
        try {
            if (String.isBlank(prompt)) {
                response.error = 'Prompt is required.';
                return response;
            }

            HttpRequest req = new HttpRequest();
            req.setEndpoint(ENDPOINT_BASE);
            req.setMethod('POST');
            req.setHeader('Content-Type', 'application/json');

            Map<String, Object> body = new Map<String, Object>();
            body.put('mode', 'preview');
            body.put('prompt', prompt);
            body.put('negative_prompt', String.isBlank(negativePrompt) ? '' : negativePrompt);
            body.put('art_style', String.isBlank(artStyle) ? 'realistic' : artStyle);
            body.put('should_remesh', shouldRemesh != null ? shouldRemesh : true);
            req.setBody(JSON.serialize(body));

            Http http = new Http();
            HttpResponse res = http.send(req);

            if (res.getStatusCode() == 200 || res.getStatusCode() == 202) {
                Map<String, Object> jsonResponse = (Map<String, Object>) JSON.deserializeUntyped(res.getBody());
                response.taskId = (String) jsonResponse.get('result');
                if (String.isBlank(response.taskId)) {
                    response.error = 'Invalid response: No task ID returned.';
                }
            } else {
                response.error = 'HTTP Error: ' + res.getStatusCode() + ' - ' + res.getBody();
            }
        } catch (Exception e) {
            response.error = 'Exception: ' + e.getMessage();
        }
        return response;
    }

    /**
     * @description Checks the status of a Meshy task.
     */
    @AuraEnabled
    public static StatusResponse checkTaskStatus(String taskId) {
        StatusResponse response = new StatusResponse();
        response.taskId = taskId;
        try {
            if (String.isBlank(taskId)) {
                response.error = 'Task ID is required.';
                return response;
            }

            HttpRequest req = new HttpRequest();
            req.setEndpoint(ENDPOINT_BASE + '/' + taskId);
            req.setMethod('GET');
            req.setHeader('Content-Type', 'application/json');

            Http http = new Http();
            HttpResponse res = http.send(req);

            if (res.getStatusCode() == 200) {
                Map<String, Object> jsonResponse = (Map<String, Object>) JSON.deserializeUntyped(res.getBody());
                response.status = (String) jsonResponse.get('status');
                if (String.isBlank(response.status)) {
                    response.error = 'Invalid response: No status returned.';
                    return response;
                }
                if (response.status == 'SUCCEEDED') {
                    Object modelUrlsObj = jsonResponse.get('model_urls');
                    if (modelUrlsObj != null) {
                        response.modelUrls = (Map<String, String>) JSON.deserialize(
                            JSON.serialize(modelUrlsObj),
                            Map<String, String>.class
                        );
                    }
                }
            } else {
                response.error = 'HTTP Error: ' + res.getStatusCode() + ' - ' + res.getBody();
            }
        } catch (Exception e) {
            response.error = 'Exception: ' + e.getMessage();
        }
        return response;
    }

    /**
     * @description Lists all Meshy Text-to-3D tasks.
     */
    @AuraEnabled
    public static List<MeshyTaskWrapper> listAllTasks() {
        try {
            HttpRequest req = new HttpRequest();
            req.setEndpoint(ENDPOINT_BASE);
            req.setMethod('GET');
            req.setHeader('Content-Type', 'application/json');

            Http http = new Http();
            HttpResponse res = http.send(req);

            if (res.getStatusCode() == 200) {
                Map<String, Object> jsonResponse = (Map<String, Object>) JSON.deserializeUntyped(res.getBody());
                List<Object> taskList = (List<Object>) jsonResponse.get('result');
                String taskListJson = JSON.serialize(taskList);
                return MeshyTaskWrapper.parse(taskListJson);
            } else {
                throw new AuraHandledException('HTTP Error: ' + res.getStatusCode() + ' - ' + res.getBody());
            }
        } catch (Exception e) {
            throw new AuraHandledException('Error listing tasks: ' + e.getMessage());
        }
    }

    /**
     * @description Fetches the Meshy API balance.
     */
    @AuraEnabled
    public static MeshyTaskWrapper.MeshyBalanceWrapper getBalance() {
        try {
            HttpRequest req = new HttpRequest();
            req.setEndpoint(BALANCE_ENDPOINT);
            req.setMethod('GET');
            req.setHeader('Content-Type', 'application/json');

            Http http = new Http();
            HttpResponse res = http.send(req);

            if (res.getStatusCode() == 200) {
                return MeshyTaskWrapper.parseBalance(res.getBody());
            } else {
                throw new AuraHandledException('HTTP Error: ' + res.getStatusCode() + ' - ' + res.getBody());
            }
        } catch (Exception e) {
            throw new AuraHandledException('Error fetching balance: ' + e.getMessage());
        }
    }

    /**
     * @description Creates an Image-to-3D task.
     */
    @AuraEnabled
    public static MeshyTaskWrapper.ImageTo3DTaskResponse createImageTo3DTask(String imageBase64) {
        MeshyTaskWrapper.ImageTo3DTaskResponse response = new MeshyTaskWrapper.ImageTo3DTaskResponse();
        try {
            if (String.isBlank(imageBase64)) {
                response.error = 'Image data is required.';
                return response;
            }

            HttpRequest req = new HttpRequest();
            req.setEndpoint(IMAGE_TO_3D_ENDPOINT);
            req.setMethod('POST');
            req.setHeader('Content-Type', 'application/json');

            Map<String, Object> body = new Map<String, Object>();
            body.put('image_base64', imageBase64);
            body.put('mode', 'preview');
            body.put('enable_pbr', false);
            req.setBody(JSON.serialize(body));

            Http http = new Http();
            HttpResponse res = http.send(req);

            if (res.getStatusCode() == 200 || res.getStatusCode() == 202) {
                return MeshyTaskWrapper.parseImageTo3DTaskResponse(res.getBody());
            } else {
                response.error = 'HTTP Error: ' + res.getStatusCode() + ' - ' + res.getBody();
                return response;
            }
        } catch (Exception e) {
            response.error = 'Exception: ' + e.getMessage();
            return response;
        }
    }
}