# MapStruct Guide

## Overview

MapStruct is a code generator that greatly simplifies the implementation of mappings between Java bean types based on a convention over configuration approach. The generated mapping code uses plain method invocations and thus is fast, type-safe, and easy to understand.

## Maven Coordinates

### Original Coordinates
```xml
<dependency>
    <groupId>org.mapstruct</groupId>
    <artifactId>mapstruct</artifactId>
    <version>1.6.3</version>
</dependency>

<!-- Annotation processor -->
<dependency>
    <groupId>org.mapstruct</groupId>
    <artifactId>mapstruct-processor</artifactId>
    <version>1.6.3</version>
    <scope>provided</scope>
</dependency>
```

### GuicedEE Coordinates
```xml
<dependency>
    <groupId>com.guicedee.services</groupId>
    <artifactId>mapstruct</artifactId>
    <version>2.0.0-SNAPSHOT</version>
</dependency>
```

## Gradle Coordinates

### Original Coordinates
```groovy
implementation 'org.mapstruct:mapstruct:1.6.3'
annotationProcessor 'org.mapstruct:mapstruct-processor:1.6.3'
```

### GuicedEE Coordinates
```groovy
implementation 'com.guicedee.services:mapstruct:2.0.0-SNAPSHOT'
```

## Module Information

### Original Module
MapStruct does not provide proper JPMS module support

### GuicedEE Module
When using the GuicedEE coordinates, the module name is:

```java
module org.mapstruct {
    exports org.mapstruct;
    exports org.mapstruct.factory;
    exports org.mapstruct.ap.spi;
    exports org.mapstruct.control;
}
```

## Basic Usage

1. Define your mapper interface:

```java
@Mapper
public interface CarMapper {
    CarMapper INSTANCE = Mappers.getMapper(CarMapper.class);

    CarDto carToCarDto(Car car);
}
```

2. Use the mapper:

```java
Car car = new Car("Toyota", 5, "red");
CarDto carDto = CarMapper.INSTANCE.carToCarDto(car);
```

## Key Features

### Property Mapping

MapStruct automatically maps properties with the same name. For properties with different names, use the `@Mapping` annotation:

```java
@Mapper
public interface CarMapper {
    @Mapping(source = "numberOfSeats", target = "seatCount")
    CarDto carToCarDto(Car car);
}
```

### Multiple Source Parameters

```java
@Mapper
public interface CarMapper {
    @Mapping(source = "car.make", target = "manufacturer")
    @Mapping(source = "person.name", target = "ownerName")
    CarDto carAndPersonToCarDto(Car car, Person person);
}
```

### Type Conversions

MapStruct handles many type conversions automatically:
- Primitive to wrapper types (and vice versa)
- String to numbers, enums, dates, etc.
- Collection types (List, Set, Map)

### Custom Mapping Methods

```java
@Mapper
public interface CarMapper {
    CarDto carToCarDto(Car car);

    default PersonDto personToPersonDto(Person person) {
        // Custom mapping logic
        PersonDto dto = new PersonDto();
        dto.setFullName(person.getFirstName() + " " + person.getLastName());
        return dto;
    }
}
```

### Mapping Inheritance

```java
@Mapper
public interface VehicleMapper {
    VehicleDto vehicleToVehicleDto(Vehicle vehicle);
}

@Mapper
public interface CarMapper extends VehicleMapper {
    @Override
    CarDto vehicleToVehicleDto(Vehicle vehicle);

    CarDto carToCarDto(Car car);
}
```

## New Features in MapStruct 1.6.3 (since 1.5.5)

### Conditional Mapping

MapStruct 1.6.x introduced improved conditional mapping with the `@Condition` annotation:

```java
@Mapper
public interface PersonMapper {
    PersonDto toDto(Person person);

    @Condition
    default boolean isNotEmpty(String value) {
        return value != null && !value.isEmpty();
    }
}
```

### Enhanced Builder Support

Improved support for builder patterns with more flexible configuration:

```java
@Mapper(builder = @Builder(
    buildMethod = "create",
    disableBuilder = false
))
public interface CarMapper {
    CarDto carToCarDto(Car car);
}
```

### Improved Record Support

MapStruct 1.6.x has enhanced support for Java Records:

```java
@Mapper
public interface PersonMapper {
    PersonDto toDto(PersonRecord person);
}
```

### Subclass Mapping Improvements

Better handling of inheritance hierarchies with more control over subclass mappings:

```java
@Mapper
public interface VehicleMapper {
    @SubclassMapping(source = Car.class, target = CarDto.class)
    @SubclassMapping(source = Truck.class, target = TruckDto.class)
    BaseVehicleDto toDto(Vehicle vehicle);
}
```

### Mapping Control

New `@MappingControl` annotation for fine-grained control over mapping behavior:

```java
@MappingControl(MappingControl.DeepClone.class)
@Mapper
public interface DeepCloneMapper {
    TargetType map(SourceType source);
}
```

### Nullability Improvements

Better handling of null values with enhanced null value property mapping:

```java
@Mapper
public interface CarMapper {
    @Mapping(target = "manufacturer", nullValuePropertyMappingStrategy = NullValuePropertyMappingStrategy.IGNORE)
    CarDto carToCarDto(Car car);
}
```

## Performance Considerations

- MapStruct generates plain Java method calls, making it very fast compared to reflection-based mapping frameworks
- No runtime dependencies are required
- Generated code is easy to debug and understand

## Best Practices

1. Use mapper interfaces with the `@Mapper` annotation
2. Define a static `INSTANCE` field for singleton access
3. Leverage MapStruct's automatic type conversions
4. Create custom mapping methods for complex transformations
5. Use `@BeanMapping(ignoreByDefault = true)` to explicitly control which properties are mapped
6. Organize related mappers using `@MapperConfig` and mapper inheritance

## Modular Implementation

When using MapStruct with Java modules (JPMS):

### Using Original Coordinates

1. Add MapStruct to your module declaration:

```java
module com.example.app {
    requires org.mapstruct;

    // Make sure annotation processor can access your mappers
    opens com.example.app.mapper to org.mapstruct.processor;
}
```

2. Configure the annotation processor in your build tool:

For Maven:
```xml
<plugin>
    <groupId>org.apache.maven.plugins</groupId>
    <artifactId>maven-compiler-plugin</artifactId>
    <version>3.11.0</version>
    <configuration>
        <annotationProcessorPaths>
            <path>
                <groupId>org.mapstruct</groupId>
                <artifactId>mapstruct-processor</artifactId>
                <version>1.6.3</version>
            </path>
        </annotationProcessorPaths>
    </configuration>
</plugin>
```

For Gradle:
```groovy
tasks.withType(JavaCompile) {
    options.annotationProcessorPath = configurations.annotationProcessor
}
```

### Using GuicedEE Coordinates

1. Add MapStruct to your module declaration:

```java
module com.example.app {
    requires org.mapstruct;

    // Make sure annotation processor can access your mappers
    opens com.example.app.mapper to org.mapstruct.processor;
}
```

2. Configure your build tool:

For Maven:
```xml
<dependency>
    <groupId>com.guicedee.services</groupId>
    <artifactId>mapstruct</artifactId>
    <version>2.0.0-SNAPSHOT</version>
</dependency>
```

For Gradle:
```groovy
implementation 'com.guicedee.services:mapstruct:2.0.0-SNAPSHOT'
```

Note: When using GuicedEE coordinates, you still need to configure the annotation processor. GuicedEE services MapStruct works exactly the same as the original, just modular.

## Troubleshooting

### Common Issues

1. **Missing mapper implementation**: Ensure the annotation processor is correctly configured
2. **Unmapped target properties**: Use `@Mapping` to explicitly map properties with different names
3. **Type conversion errors**: Provide custom mapping methods for complex type conversions
4. **Cyclic dependencies**: Use `@Context` to break cycles or create separate mappers

### Debugging Tips

1. Enable verbose MapStruct processing:
   ```
   -Amapstruct.verbose=true
   ```

2. Check the generated implementation classes in your build directory
3. Use IDE debugging to step through the generated code
