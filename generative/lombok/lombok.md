# Lombok in Maven Projects

## Overview

Project Lombok is a Java library that automatically plugs into your editor and build tools, spicing up your Java. It reduces boilerplate code for model/data objects by providing annotations like `@Data`, `@Getter`, `@Setter`, etc.

This guide covers how to set up and use Lombok in Maven projects, with special considerations for integration with MapStruct and Hibernate.

## Latest Version

The latest version of Lombok is **1.18.40**, which is required for JDK 24 and above.

## Basic Maven Configuration

Add the following to your `pom.xml`:

```xml
<properties>
    <lombok.version>1.18.40</lombok.version>
</properties>

<dependencies>
    <dependency>
        <groupId>org.projectlombok</groupId>
        <artifactId>lombok</artifactId>
        <version>${lombok.version}</version>
        <scope>provided</scope>
    </dependency>
</dependencies>
```

## IDE Setup

For Lombok to work properly in your IDE, you need to install the Lombok plugin:

- **IntelliJ IDEA**: Install the "Lombok" plugin from the marketplace and enable annotation processing
- **Eclipse**: Run the Lombok installer (lombok.jar) and restart Eclipse
- **VS Code**: Install the "Lombok Annotations Support for VS Code" extension

## Using Lombok with MapStruct

[MapStruct](https://mapstruct.org/) is a code generator that simplifies the implementation of mappings between Java bean types. When using Lombok with MapStruct, you need to configure the annotation processors correctly.

### Maven Configuration for Lombok with MapStruct

```xml
<properties>
    <lombok.version>1.18.40</lombok.version>
    <mapstruct.version>1.6.3.Final</mapstruct.version>
    <lombok-mapstruct-binding.version>0.2.0</lombok-mapstruct-binding.version>
</properties>

<dependencies>
    <!-- Lombok -->
    <dependency>
        <groupId>org.projectlombok</groupId>
        <artifactId>lombok</artifactId>
        <version>${lombok.version}</version>
        <scope>provided</scope>
    </dependency>

    <!-- MapStruct -->
    <dependency>
        <groupId>org.mapstruct</groupId>
        <artifactId>mapstruct</artifactId>
        <version>${mapstruct.version}</version>
    </dependency>
</dependencies>

<build>
    <plugins>
        <plugin>
            <groupId>org.apache.maven.plugins</groupId>
            <artifactId>maven-compiler-plugin</artifactId>
            <configuration>
                <annotationProcessorPaths>
                    <!-- Lombok must come before MapStruct -->
                    <path>
                        <groupId>org.projectlombok</groupId>
                        <artifactId>lombok</artifactId>
                        <version>${lombok.version}</version>
                    </path>
                    <path>
                        <groupId>org.mapstruct</groupId>
                        <artifactId>mapstruct-processor</artifactId>
                        <version>${mapstruct.version}</version>
                    </path>
                    <!-- This is needed for Lombok and MapStruct to work together -->
                    <path>
                        <groupId>org.projectlombok</groupId>
                        <artifactId>lombok-mapstruct-binding</artifactId>
                        <version>${lombok-mapstruct-binding.version}</version>
                    </path>
                </annotationProcessorPaths>
            </configuration>
        </plugin>
    </plugins>
</build>
```

### Important Considerations

1. The `lombok-mapstruct-binding` dependency is crucial for Lombok and MapStruct to work together properly.
2. The order of annotation processors matters: Lombok should be processed before MapStruct.
3. Remember to use explicit @Getter, @Setter, and @EqualsAndHashCode annotations instead of @Data, especially for entity classes.

## Using Lombok with Hibernate Processor

When using Lombok with Hibernate's annotation processor (formerly known as Hibernate JPA generator), you need to configure the annotation processors correctly.

### Maven Configuration for Lombok with Hibernate Processor

The versions are inherited from the parents

```xml
<dependencies>
    <!-- Lombok -->
    <dependency>
        <groupId>org.projectlombok</groupId>
        <artifactId>lombok</artifactId>
        <version>${lombok.version}</version>
        <scope>provided</scope>
    </dependency>

    <!-- Hibernate -->
    <dependency>
        <groupId>org.hibernate.orm</groupId>
        <artifactId>hibernate-core</artifactId>
        <version>${hibernate.version}</version>
    </dependency>
</dependencies>

<build>
    <plugins>
        <plugin>
            <groupId>org.apache.maven.plugins</groupId>
            <artifactId>maven-compiler-plugin</artifactId>
            <configuration>
                <annotationProcessorPaths>
                    <!-- Lombok should come first -->
                    <path>
                        <groupId>org.projectlombok</groupId>
                        <artifactId>lombok</artifactId>
                        <version>${lombok.version}</version>
                    </path>
                    <annotationProcessorPath>
                        <groupId>org.hibernate.orm</groupId>
                        <artifactId>hibernate-processor</artifactId>
                        <version>${hibernate.version}</version>
                    </annotationProcessorPath>
                </annotationProcessorPaths>
            </configuration>
        </plugin>
    </plugins>
</build>
```

## Using Lombok with Both MapStruct and Hibernate Processor

When using Lombok with both MapStruct and Hibernate processor, the configuration becomes more complex. Here's a complete example:

```xml
<dependencies>
    <!-- Lombok -->
    <dependency>
        <groupId>org.projectlombok</groupId>
        <artifactId>lombok</artifactId>
        <version>${lombok.version}</version>
        <scope>provided</scope>
    </dependency>

    <!-- MapStruct -->
    <dependency>
        <groupId>org.mapstruct</groupId>
        <artifactId>mapstruct</artifactId>
        <version>${mapstruct.version}</version>
    </dependency>

    <!-- Hibernate -->
    <dependency>
        <groupId>org.hibernate.orm</groupId>
        <artifactId>hibernate-core</artifactId>
        <version>${hibernate.version}</version>
    </dependency>
</dependencies>

<build>
    <plugins>
        <plugin>
            <groupId>org.apache.maven.plugins</groupId>
            <artifactId>maven-compiler-plugin</artifactId>
            <configuration>
                <annotationProcessorPaths>
                    <annotationProcessorPath>
                        <groupId>org.hibernate.orm</groupId>
                        <artifactId>hibernate-processor</artifactId>
                        <version>${hibernate.version}</version>
                    </annotationProcessorPath>
                    <path>
                        <groupId>org.projectlombok</groupId>
                        <artifactId>lombok</artifactId>
                        <version>${lombok.version}</version>
                    </path>
                    <path>
                        <groupId>org.mapstruct</groupId>
                        <artifactId>mapstruct-processor</artifactId>
                        <version>${mapstruct.version}</version>
                    </path>
                    <path>
                        <groupId>org.projectlombok</groupId>
                        <artifactId>lombok-mapstruct-binding</artifactId>
                        <version>0.2.0</version>
                    </path>
                </annotationProcessorPaths>
                <annotationProcessors>
                    <annotationProcessor>lombok.launch.AnnotationProcessorHider$AnnotationProcessor</annotationProcessor>
                    <annotationProcessor>org.hibernate.processor.HibernateProcessor</annotationProcessor>
                    <annotationProcessor>org.mapstruct.ap.MappingProcessor</annotationProcessor>
                </annotationProcessors>
                <failOnError>true</failOnError>
                </configuration>
                <dependencies>
                    <dependency>
                        <groupId>org.projectlombok</groupId>
                        <artifactId>lombok</artifactId>
                        <version>${lombok.version}</version>
                    </dependency>
                    <dependency>
                        <groupId>jakarta.xml.bind</groupId>
                        <artifactId>jakarta.xml.bind-api</artifactId>
                        <version>${jakarta.xml.jaxb.api.version}</version>
                    </dependency>
                </dependencies>
            </plugin>
        </plugins>
    </build>
```

## Annotation Processor Ordering

The order of annotation processors is crucial when using multiple processors together. Here are the key considerations:

1. **Lombok First**: Lombok should generally be processed first, as it generates code that other processors might need.
2. **Hibernate Processor**: The Hibernate processor should come after Lombok but before MapStruct.
3. **MapStruct Last**: MapStruct should typically be the last processor, as it needs to see the final state of the classes after other processors have run.

The explicit ordering in the `<annotationProcessors>` section ensures that processors run in the correct sequence:

```xml
<annotationProcessors>
    <annotationProcessor>lombok.launch.AnnotationProcessorHider$AnnotationProcessor</annotationProcessor>
    <annotationProcessor>org.hibernate.processor.HibernateProcessor</annotationProcessor>
    <annotationProcessor>org.mapstruct.ap.MappingProcessor</annotationProcessor>
</annotationProcessors>
```

## Common Lombok Annotations

Here are the recommended Lombok annotations for our projects:

- `@Getter` / `@Setter`: Generate getters and setters for fields. These should always be explicitly specified rather than using @Data.
- `@NoArgsConstructor` / `@AllArgsConstructor` / `@RequiredArgsConstructor`: Generate constructors
- `@ToString`: Generate toString() method
- `@EqualsAndHashCode`: Generate equals() and hashCode() methods. This should always be explicitly specified rather than using @Data.
- `@Log4J2`: Creates a Log4J2 logger field. This is our standard logging annotation.

### Annotations to Avoid

- `@Builder`: We prefer using the Curiously Recurring Template Pattern (CRTP) instead of the Builder pattern.
- `@Data`: Never use @Data for entities. Always use @Getter, @Setter, and @EqualsAndHashCode explicitly.

## Best Practices

1. **Use Lombok Judiciously**: Don't overuse Lombok annotations. Sometimes explicit code is clearer.
2. **Never Use @Data for Entities**: Always use @Getter, @Setter, and @EqualsAndHashCode explicitly for entity classes.
3. **Always Use @Log4J2**: For logging, always use @Log4J2 instead of other logging annotations.
4. **Avoid @Builder**: Use the Curiously Recurring Template Pattern (CRTP) instead of the Builder pattern.
5. **Watch for Circular References**: Be careful with @ToString and @EqualsAndHashCode on entities with bidirectional relationships.
6. **Specify Version**: Always specify the Lombok version explicitly to avoid compatibility issues.
7. **Keep Lombok Updated**: Regularly update to the latest version for bug fixes and new features.

## Troubleshooting

### Common Issues

1. **Compilation Errors**: Ensure that the annotation processor paths are correctly configured.
2. **IDE Not Recognizing Lombok**: Make sure the Lombok plugin is installed and annotation processing is enabled.
3. **MapStruct Not Generating Mappers**: Check the order of annotation processors.
4. **Hibernate Processor Issues**: Verify that the Hibernate processor is correctly configured.

### Solutions

1. **Clean and Rebuild**: Often, a simple clean and rebuild can resolve issues.
2. **Check Versions**: Ensure that all versions are compatible with each other.
3. **Explicit Annotation Processors**: Use the `<annotationProcessors>` section to explicitly define the order.
4. **Lombok Config**: Create a `lombok.config` file in your project root to customize Lombok behavior.

## Lombok Configuration File

Lombok provides a way to customize its behavior through a `lombok.config` file placed in your project root. This file allows you to set project-wide defaults and behaviors.

### Required Configuration

For our projects, you must create a `lombok.config` file in your project root with the following configuration:

```
# Enable fluent accessors (allows method chaining)
lombok.accessors.chain=true
```

This configuration enables method chaining for all generated setters, allowing you to write code like:

```
// Example of method chaining with accessors.chain=true
user.setFirstName("John")
    .setLastName("Doe")
    .setEmail("john.doe@example.com");
```

### Additional Configuration Options

You can also add other configuration options as needed:

```
# Disable specific warnings
lombok.extern.findbugs.addSuppressFBWarnings=true

# Configure @ToString to include field names
lombok.toString.includeFieldNames=true

# Configure @EqualsAndHashCode to not use getters
lombok.equalsAndHashCode.doNotUseGetters=true
```

For a complete list of configuration options, refer to the [Lombok Configuration System documentation](https://projectlombok.org/features/configuration).

## Conclusion

Lombok can significantly reduce boilerplate code in your Java projects, but it requires careful configuration, especially when used with other annotation processors like MapStruct and Hibernate. By following the guidelines in this document, you can ensure that Lombok works seamlessly in your Maven projects.
