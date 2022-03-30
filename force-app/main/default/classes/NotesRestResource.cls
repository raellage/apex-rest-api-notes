@RestResource(urlMapping='/api/notes/*')
global with sharing class NotesRestResource {
    
    ///services/apexrest/api/notes/0023h0000029FyiAAE
    @HttpGet
    global static void doGet() {
        RestRequest request = RestContext.request;
        RestResponse response = RestContext.response;
        response.addHeader('Content-Type', 'application/json');

        try {            
            String noteId = request.requestURI.substring(request.requestURI.lastIndexOf('/')+1);

            if(noteId == 'notes' || noteId == '') {
                List<Note> responseNotes = new List<Note>();
                responseNotes = [SELECT Id, Title, Body, ParentId FROM Note];
                response.responseBody = Blob.valueOf(JSON.serializePretty(responseNotes));
            } else {
                Note responseNote = new Note();
                responseNote = [SELECT Id, Title, Body, ParentId FROM Note WHERE Id = :noteId];
                response.responseBody = Blob.valueOf(JSON.serializePretty(responseNote));                
            }            
            
            response.statusCode = 200;
        } catch (Exception ex) {
            ResponseWrapper objResponse = new ResponseWrapper();
            objResponse.errorCode = ex.getTypeName();
            objResponse.message = ex.getMessage();

            response.statusCode = 500;
            response.responseBody = Blob.valueOf(JSON.serializePretty(objResponse));
        }
    }

    ///services/apexrest/api/notes
    @HttpPost
    global static void doPost() {
        RestRequest request = RestContext.request;
        RestResponse response = RestContext.response;
        response.addHeader('Content-Type', 'application/json');

        try {            
            String body = request.requestBody.toString().trim();
            List<NoteWrapper> notesWrapper = (List<NoteWrapper>) JSON.deserialize(body, List<NoteWrapper>.class);
            
            List<Note> notesToInsert =  new List<Note>();            

            for (NoteWrapper noteWrapper : notesWrapper) {
                Note newNote = new Note();
                newNote.Title = noteWrapper.title;
                newNote.Body = noteWrapper.body;
                newNote.ParentId = noteWrapper.relatedId;

                notesToInsert.add(newNote);
            }

            insert notesToInsert;
            
            response.statusCode = 200;
            response.responseBody = Blob.valueOf(JSON.serializePretty(notesToInsert));
        } catch (Exception ex) {
            ResponseWrapper objResponse = new ResponseWrapper();
            objResponse.errorCode = String.valueOf(ex.getTypeName());
            objResponse.message = ex.getMessage();

            response.statusCode = 500;
            response.responseBody = Blob.valueOf(JSON.serializePretty(objResponse));
        }
    }
    
}