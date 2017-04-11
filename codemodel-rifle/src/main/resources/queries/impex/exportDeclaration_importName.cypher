MATCH
// export.js: export var name1;
    (exporter:CompilationUnit)-[:contains]->(:ExportDeclaration)
        -[:declaration]->(:FunctionDeclarationClassDeclarationVariableDeclaration)-[:declarators]->(:VariableDeclarator)
        -[:binding]->(exportBindingIdentifier:BindingIdentifier)<-[:node]-(declarationToMerge:Declaration)
        <-[:declarations]-(:Variable),

// import.js: import { name1 } from "exporter";
    (importer:CompilationUnit)-[:contains]->(import:Import)-[:namedImports]->(importSpecifier:ImportSpecifier)
        -[:binding]->(importBindingIdentifierToMerge:BindingIdentifier)<-[:node]-(declarationToDelete:Declaration)
        <-[:declarations]-(importedVariable:Variable)

    WHERE
    exporter.parsedFilePath CONTAINS import.moduleSpecifier
    AND exportBindingIdentifier.name = importBindingIdentifierToMerge.name

CREATE UNIQUE
    (importedVariable)-[:declarations]->(declarationToMerge),
    (declarationToMerge)-[:node]->(importBindingIdentifierToMerge)

DETACH DELETE
declarationToDelete
;
