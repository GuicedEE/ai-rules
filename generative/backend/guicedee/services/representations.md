# Representations in GuicedEE

## Overview

Representations in GuicedEE are domain-driven interfaces that provide a way to produce object representations of a specified type. They follow the Curiously Recurring Template Pattern (CRTP) to enable type-safe, fluent interfaces for converting between domain objects and various representation formats.

The project currently supports three representation types:
- JSON Representation
- XML Representation
- Excel Representation

Each representation type provides a consistent interface for converting domain objects to and from the respective format, while maintaining type safety and domain-driven design principles.

## Core Concepts

### Domain-Driven Interfaces

Representations are designed as interfaces that domain objects can implement to gain the ability to be represented in different formats. This approach follows domain-driven design principles by:

1. Keeping the representation logic separate from the domain logic
2. Allowing domain objects to be represented in multiple formats without changing their core behavior
3. Providing a consistent interface across different representation types

### Curiously Recurring Template Pattern (CRTP)

The JSON and XML representations use the Curiously Recurring Template Pattern (CRTP) through generic type parameters. This pattern allows for:

1. Type-safe fluent interfaces
2. Self-referential generic types
3. Method chaining with proper return types

Example from `IJsonRepresentation<J>`:
```java
public interface IJsonRepresentation<J> extends Serializable {
    default J fromJson(String json) {
        // Implementation that returns the implementing class type
    }
}
```

When a class implements this interface, it specifies itself as the generic parameter:
```java
public class User implements IJsonRepresentation<User> {
    // Now fromJson() returns User type
}
```

## JSON Representation

### Core Classes

- **IJsonRepresentation<J>**: The main interface for JSON representation
  - Provides methods for converting objects to JSON (`toJson()`)
  - Provides methods for parsing JSON into objects (`fromJson()`)
  - Includes static utility methods for reading JSON from various sources

- **ObjectMapperBinder**: Configures and binds Jackson's ObjectMapper
  - Registers custom serializers and deserializers
  - Configures serialization/deserialization settings
  - Provides different ObjectMapper instances for different use cases

- **LaxJsonModule**: A Jackson SimpleModule that registers custom serializers and deserializers
  - Makes JSON processing more flexible and robust
  - Handles various date/time formats and conversions

### Custom Serializers and Deserializers

#### Date/Time Serializers
- **InstantSerializer/Deserializer**: Handles Java 8 Instant type
- **LocalDateSerializer/Deserializer**: Handles Java 8 LocalDate type
- **LocalDateTimeSerializer/Deserializer**: Handles Java 8 LocalDateTime type
- **LocalTimeSerializer/Deserializer**: Handles Java 8 LocalTime type
- **OffsetDateTimeSerializer/Deserializer**: Handles Java 8 OffsetDateTime type
- **OffsetTimeSerializer/Deserializer**: Handles Java 8 OffsetTime type
- **ZonedDateTimeSerializer/Deserializer**: Handles Java 8 ZonedDateTime type

#### Duration Serializers
- **DurationToInteger**: Converts Duration to integer representation
- **DurationToString**: Converts Duration to string representation
- **StringToDurationTime**: Converts string to Duration
- **StringToDurationTimeSeconds**: Converts string to Duration with seconds precision

#### String Conversion Serializers
- **StringToBool**: Converts string to boolean primitive
- **StringToBoolean**: Converts string to Boolean object
- **StringToCharacterSet**: Converts string to CharacterSet
- **StringToIntegerRelaxed**: Converts string to Integer with relaxed parsing
- **StringToIntRelaxed**: Converts string to int primitive with relaxed parsing

#### Map Key Deserializers
- **LocalDateDeserializerKey**: Deserializes LocalDate as map key
- **LocalDateTimeDeserializerKey**: Deserializes LocalDateTime as map key
- **OffsetDateTimeDeserializerKey**: Deserializes OffsetDateTime as map key

## XML Representation

### Core Classes

- **IXmlRepresentation<J>**: The main interface for XML representation
  - Provides methods for converting objects to XML (`toXml()`)
  - Provides methods for parsing XML into objects (`fromXml()`)
  - Includes configuration options for XML processing

- **XmlContexts**: Caches JAXBContext instances for performance
  - Avoids creating new JAXBContext instances for the same class

### Serialization Mechanism

XML representation uses JAXB (Jakarta XML Binding) for XML processing:
- **Marshalling**: Converting Java objects to XML
- **Unmarshalling**: Converting XML to Java objects
- **JAXBContext**: Provides the entry point to the JAXB API
- **JAXBIntrospector**: Examines JAXB objects to determine if they have an XML element name

## Excel Representation

### Core Classes

- **IExcelRepresentation**: The main interface for Excel representation
  - Provides methods for reading Excel files into object representations (`fromExcel()`)
  - Provides a placeholder method for converting objects to Excel format (`toExcel()`)

- **ExcelReader**: Handles reading Excel files and converting to objects
  - Supports both XLSX and XLS formats
  - Provides methods for reading rows and columns
  - Converts Excel data to Java objects using JSON as an intermediate format

### Serialization Mechanism

Excel representation uses Apache POI for Excel processing:
- **Reading**: Converting Excel files to Java objects
  1. Reads Excel file using Apache POI
  2. Extracts headers from the first row
  3. Converts each row to a JSON object
  4. Converts JSON objects to Java objects using Jackson

## Implementation Examples

### JSON Representation Example

```java
public class User implements IJsonRepresentation<User> {
    private String name;
    private int age;
    
    // Getters and setters
    
    // Now User has toJson() and fromJson() methods
    // Example usage:
    // String json = user.toJson();
    // User updatedUser = user.fromJson(json);
}
```

### XML Representation Example

```java
@XmlRootElement
public class Product implements IXmlRepresentation<Product> {
    private String name;
    private BigDecimal price;
    
    // Getters and setters
    
    // Now Product has toXml() and fromXml() methods
    // Example usage:
    // String xml = product.toXml();
    // Product updatedProduct = product.fromXml(xml, Product.class);
}
```

### Excel Representation Example

```java
public class Employee implements IExcelRepresentation {
    private String name;
    private String department;
    private int employeeId;
    
    // Getters and setters
    
    // Now Employee can be read from Excel
    // Example usage:
    // List<Employee> employees = employee.fromExcel(inputStream, Employee.class, "Employees");
}
```

## Best Practices

1. **Implement the appropriate representation interface** based on your needs
2. **Use CRTP** for type-safe fluent interfaces
3. **Keep domain logic separate** from representation logic
4. **Use custom serializers** for complex types
5. **Cache context objects** for performance (already done for JAXBContext in XML representation)