MATCH
// export.js: export var name1;
    (exporter:CompilationUnit)-[:contains]->(:ExportDeclaration)-[:declaration]->(:VariableDeclaration)
        -[:declarators]->(:VariableDeclarator)-[:binding]->(exportBindingIdentifier:BindingIdentifier)
        <-[:node]-(declarationToMerge:Declaration)<--(declarationListToMerge:List)<-[:declarations]-(:Variable),

// import.js: import { name1 as importedName1 } from "exporter";
    (importer:CompilationUnit)-[:contains]->(import:Import)-[:namedImports]->(importSpecifier:ImportSpecifier)
        -[:binding]->(importBindingIdentifierToMerge:BindingIdentifier)<-[:node]-(declarationToDelete:Declaration)
        <--(declarationListToDelete:List)<-[:declarations]-(importedVariable:Variable)

    WHERE
    exporter.parsedFilePath CONTAINS import.moduleSpecifier
    AND exportBindingIdentifier.name = importSpecifier.name

CREATE UNIQUE
    (importedVariable)-[:declarations]->(declarationToMerge),
    (importedVariable)-[:declarations]->(declarationListToMerge),
    (declarationToMerge)-[:node]->(importBindingIdentifierToMerge)

DETACH DELETE
declarationToDelete,
declarationListToDelete
;